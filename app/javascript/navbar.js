console.log('application.js loaded');
export function setupNavbar() {
  const burger = document.querySelector('.navbar-burger');
  const menu = document.querySelector('#navbarBasicExample');

  if (burger && menu) {
    burger.addEventListener('click', () => {
      burger.classList.toggle('is-active');
      menu.classList.toggle('is-active');
    });

    // メニュー内のリンクをクリックしたときに閉じる
    const menuItems = menu.querySelectorAll('.navbar-item');
    menuItems.forEach(item => {
      item.addEventListener('click', () => {
        burger.classList.remove('is-active');
        menu.classList.remove('is-active');
      });
    });
  }
}