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
    function fetchAuthors(term = "", showDropdown = false) {
      if (authorController) authorController.abort();
      authorController = new AbortController();
      authorTagify.loading(true);
      const url = term ? `/authors/autocomplete?term=${encodeURIComponent(term)}` : `/authors/autocomplete`;
      fetch(url, {
        credentials: "same-origin",
        signal: authorController.signal,
      })
        .then((r) => (r.ok ? r.json() : Promise.resolve([])))
        .then((data) => {
          // APIレスポンスが空でもwhitelistを空にしない
          const apiValues = Array.isArray(data) ? data : [];
          authorTagify.whitelist = apiValues.length > 0 ? apiValues : authorTagify.whitelist;
          authorTagify.loading(false);
          if (showDropdown) authorTagify.dropdown.show(term);
        })
        .catch((err) => {
          authorTagify.loading(false);
          // whitelistは前回のまま維持
          console.warn("authors autocomplete failed", err);
        });
    }
    authorTagify.on("input", (e) => {
      fetchAuthors(e.detail.value || "", true);
    });
    authorInput.addEventListener("focus", () => {
      fetchAuthors(authorInput.value || "", true);
    });
    authorTagify.on("change", () => {
      setupAuthorInputValidation();
    });
  // 初期化時は候補のみセット（ドロップダウンは表示しない）
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
    function fetchTags(term = "", showDropdown = false) {
      if (tagController) tagController.abort();
      tagController = new AbortController();
      tagTagify.loading(true);
      const url = term ? `/tags/autocomplete?term=${encodeURIComponent(term)}` : `/tags/autocomplete`;
      fetch(url, {
        credentials: "same-origin",
        signal: tagController.signal,
      })
        .then((r) => (r.ok ? r.json() : Promise.resolve([])))
        .then((data) => {
          // APIレスポンスが空でもwhitelistを空にしない
          const apiValues = Array.isArray(data) ? data : [];
          tagTagify.whitelist = apiValues.length > 0 ? apiValues : tagTagify.whitelist;
          tagTagify.loading(false);
          if (showDropdown) tagTagify.dropdown.show(term);
        })
        .catch((err) => {
          tagTagify.loading(false);
          // whitelistは前回のまま維持
          console.warn("tags autocomplete failed", err);
        });
    }
    tagTagify.on("input", (e) => {
      fetchTags(e.detail.value || "", true);
    });
    tagInput.addEventListener("focus", () => {
      fetchTags(tagInput.value || "", true);
    });
    // タグ用バリデーション関数（必要に応じてbook_form_validation.jsで定義）
    tagTagify.on("change", () => {
      if (typeof setupTagInputValidation === "function") {
        setupTagInputValidation();
      }
    });
  // 初期化時は候補のみセット（ドロップダウンは表示しない）
  fetchTags();
  }
});
