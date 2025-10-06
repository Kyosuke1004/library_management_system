// app/javascript/author_tagify.js
import Tagify from "tagify";

document.addEventListener("turbo:load", () => {
  const input = document.querySelector("input#author-input");
  if (!input) return;

  const tagify = new Tagify(input, {
    whitelist: [],
    dropdown: { position: "input", enabled: 0 },
    // 送信フォーマットをカンマ区切りにしたい場合は追加
    originalInputValueFormat: (valuesArr) =>
      valuesArr.map((item) => item.value).join(", "),
  });

  // 直前の通信をキャンセルするためのコントローラ
  let controller = null;

  function fetchAuthors(term = "") {
    // 前回のリクエストがあればキャンセル
    if (controller) controller.abort();
    controller = new AbortController();

    // ローディング開始（Tagify の組み込みローダーを表示）
    tagify.loading(true);

    fetch(`/authors/autocomplete?term=${encodeURIComponent(term)}`, {
      credentials: "same-origin",
      signal: controller.signal,
    })
      .then((r) => (r.ok ? r.json() : Promise.resolve([])))
      .then((data) => {
        // インスタンスプロパティに代入
        tagify.whitelist = Array.isArray(data) ? data : [];

        // ローディング終了
        tagify.loading(false);

        // 入力値でドロップダウンを再表示・フィルタリング
        if (term) tagify.dropdown.show(term);
      })
      .catch((err) => {
        // Abort の場合もここに来るのでローディング終了しておく
        tagify.loading(false);
        // エラー時は空にしておく
        tagify.whitelist = [];
        console.warn("authors autocomplete failed", err);
      });
  }

  // 入力ごとにサジェストを更新
  tagify.on("input", (e) => {
    fetchAuthors(e.detail.value || "");
  });

  // 初期候補取得
  fetchAuthors();
});
