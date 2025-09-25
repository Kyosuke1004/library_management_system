// app/javascript/book_form_validation.js
export function setupAuthorInputValidation() {
  const titleInput = document.getElementById('book_title');
  const authorInput = document.getElementById('author-input');
  const publisherInput = document.getElementById('book_publisher');
  const yearInput = document.getElementById('book_published_year');
  const isbnInput = document.getElementById('book_isbn');
  const submitBtn = document.querySelector('input[type="submit"], button[type="submit"]');

  if (!titleInput || !authorInput || !publisherInput || !yearInput || !isbnInput || !submitBtn) return;

  function validate() {
    if (
      titleInput.value.trim() === '' ||
      authorInput.value.trim() === '' ||
      publisherInput.value.trim() === '' ||
      yearInput.value.trim() === '' ||
      isbnInput.value.trim() === ''
    ) {
      submitBtn.disabled = true;
      submitBtn.classList.add('is-disabled');
    } else {
      submitBtn.disabled = false;
      submitBtn.classList.remove('is-disabled');
    }
  }

  [titleInput, authorInput, publisherInput, yearInput, isbnInput].forEach(input => {
    input.addEventListener('input', validate);
  });
  validate();
}
