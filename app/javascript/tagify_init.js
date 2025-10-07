import Tagify from "tagify";
import { setupAuthorInputValidation } from "book_form_validation";

document.addEventListener("turbo:load", () => {
  // 著者用Tagify初期化
  const authorInput = document.querySelector("input#author-input");
  if (authorInput) {
    const authorTagify = new Tagify(authorInput, {
      whitelist: [],
      dropdown: { position: "input", enabled: 0 },
      originalInputValueFormat: (valuesArr) =>
        valuesArr.map((item) => item.value).join(", "),
    });

    let authorController = null;
    function fetchAuthors(term = "") {
      if (authorController) authorController.abort();
      authorController = new AbortController();
      authorTagify.loading(true);
      fetch(`/authors/autocomplete?term=${encodeURIComponent(term)}`, {
        credentials: "same-origin",
        signal: authorController.signal,
      })
        .then((r) => (r.ok ? r.json() : Promise.resolve([])))
        .then((data) => {
          authorTagify.whitelist = Array.isArray(data) ? data : [];
          authorTagify.loading(false);
          if (term) authorTagify.dropdown.show(term);
        })
        .catch((err) => {
          authorTagify.loading(false);
          authorTagify.whitelist = [];
          console.warn("authors autocomplete failed", err);
        });
    }
    authorTagify.on("input", (e) => {
      fetchAuthors(e.detail.value || "");
    });
    authorTagify.on("change", () => {
      setupAuthorInputValidation();
    });
    fetchAuthors();
  }

  // タグ用Tagify初期化
  const tagInput = document.querySelector("input#tag-input");
  if (tagInput) {
    const tagTagify = new Tagify(tagInput, {
      whitelist: [],
      dropdown: {
         maxItems: 20,
        classname: "tags-look",
        enabled: 0,
        closeOnSelect: false
      },
      originalInputValueFormat: (valuesArr) =>
        valuesArr.map((item) => item.value).join(", "),
    });

    let tagController = null;
    function fetchTags(term = "") {
      if (tagController) tagController.abort();
      tagController = new AbortController();
      tagTagify.loading(true);
      fetch(`/tags/autocomplete?term=${encodeURIComponent(term)}`, {
        credentials: "same-origin",
        signal: tagController.signal,
      })
        .then((r) => (r.ok ? r.json() : Promise.resolve([])))
        .then((data) => {
          tagTagify.whitelist = Array.isArray(data) ? data : [];
          tagTagify.loading(false);
          if (term) tagTagify.dropdown.show(term);
        })
        .catch((err) => {
          tagTagify.loading(false);
          tagTagify.whitelist = [];
          console.warn("tags autocomplete failed", err);
        });
    }
    tagTagify.on("input", (e) => {
      fetchTags(e.detail.value || "");
    });
    // タグ用バリデーション関数（必要に応じてbook_form_validation.jsで定義）
    tagTagify.on("change", () => {
      if (typeof setupTagInputValidation === "function") {
        setupTagInputValidation();
      }
    });
    fetchTags();
  }
});
