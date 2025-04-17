// This file is automatically compiled by Webpacker
require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

require("./reviews");

console.log('Application pack loaded')
// app/javascript/packs/application.js
document.addEventListener('turbolinks:load', function () {
    const searchInput = document.getElementById('search-input');
    const searchSuggestions = document.getElementById('search-suggestions');

    if (searchInput) {
        searchInput.addEventListener('input', function () {
            const query = searchInput.value;
            if (query.length > 0) {
                fetch(`/products/search_suggestions?q[title_cont]=${query}`, {
                    headers: {
                        'Accept': 'text/vnd.turbo-stream.html'
                    }
                })
                    .then(response => response.text())
                    .then(html => {
                        searchSuggestions.innerHTML = html;
                        searchSuggestions.style.display = 'block';
                    });
            } else {
                searchSuggestions.innerHTML = '';
                searchSuggestions.style.display = 'none';
            }
        });

        document.addEventListener('click', function (event) {
            if (!searchSuggestions.contains(event.target) && !searchInput.contains(event.target)) {
                searchSuggestions.innerHTML = '';
                searchSuggestions.style.display = 'none';
            }
        });
    }
});
