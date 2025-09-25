(function() {

  function debounce(fn, wait) {
    let timeout;
    return (...args) => {
      clearTimeout(timeout);
      timeout = setTimeout(() => fn.apply(this, args), wait);
    };
  }

  function createContainer(parent) {
    let container = document.getElementById("author-suggestions");
    if (!container) {
      container = document.createElement("div");
      container.id = "author-suggestions";
      parent.appendChild(container);
    }
    Object.assign(container.style, {
      position: "absolute",
      zIndex: "1000",
      backgroundColor: "#fff",
      color: "#111",
      borderRadius: "4px",
      boxShadow: "0 8px 24px rgba(0,0,0,0.08)",
      display: "none",
    });
    return container;
  }

  function updatePosition(container, input) {
    container.style.top = input.offsetHeight + "px";
    container.style.left = "0px";
    container.style.width = input.offsetWidth + "px";
  }

  function clearContainer(container) {
    container.innerHTML = "";
    container.style.display = "none";
  }

  function renderSuggestions(container, input, names) {
    clearContainer(container);
    if (!names || names.length === 0) return;

    updatePosition(container, input);
    container.style.display = "block";

    const list = document.createElement("div");
    list.className = "menu";

    names.forEach(name => {
      const item = document.createElement("a");
      Object.assign(item.style, {
        display: "block",
        padding: "6px 8px",
        cursor: "pointer"
      });
      item.className = "menu-item";
      item.textContent = name;
      item.addEventListener("mousedown", e => {
        e.preventDefault();
        const parts = input.value.split(",");
        parts[parts.length - 1] = name;
        input.value = parts.map(p => p.trim()).filter(Boolean).join(", ") + ", ";
        clearContainer(container);
        input.focus();
      });
      list.appendChild(item);
    });

    container.appendChild(list);
  }

  function fetchSuggestions(container, input) {
    return debounce((term) => {
      if (!term) return clearContainer(container);

      fetch(`/authors/autocomplete?term=${encodeURIComponent(term)}`, { credentials: "same-origin" })
        .then(r => r.ok ? r.json() : Promise.reject("network error"))
        .then(data => renderSuggestions(container, input, data))
        .catch(() => clearContainer(container));
    }, 250);
  }

  function initAuthorAutocomplete() {
    if (document.body.dataset.authorAutocompleteInitialized === "true") return;
    document.body.dataset.authorAutocompleteInitialized = "true";

    const input = document.getElementById("author-input");
    if (!input) return;

    const container = createContainer(input.parentElement);
    const debouncedFetch = fetchSuggestions(container, input);

    input.addEventListener("input", () => {
      const last = input.value.split(",").pop().trim();
      debouncedFetch(last);
    });

    input.addEventListener("blur", () => setTimeout(() => clearContainer(container), 150));
    input.addEventListener("focus", () => updatePosition(container, input));
    window.addEventListener("resize", () => updatePosition(container, input));
  }

  document.addEventListener("DOMContentLoaded", initAuthorAutocomplete);
  document.addEventListener("turbo:load", initAuthorAutocomplete);

})();
