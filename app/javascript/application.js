// This file is automatically compiled by Webpacker
require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
// app/javascript/packs/application.js
// app/javascript/packs/application.js
// Add this after requiring Rails UJS
console.log('Rails UJS loaded:', typeof Rails !== 'undefined')
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM loaded, checking delete links...')
    document.querySelectorAll('a[data-method="delete"]').forEach(link => {
        console.log('Found delete link:', link)
    })
})
import "../javascript/carousel"
