document.addEventListener("DOMContentLoaded", function () {
    const input = document.getElementById("search-input");
    const suggestionsBox = document.getElementById("search-suggestions");

    if (!input || !suggestionsBox) return;

    input.addEventListener("keyup", function () {
        const query = input.value;

        if (query.length > 1) {
            Rails.ajax({
                url: `/products/suggestions?q[title_cont]=${encodeURIComponent(query)}`,
                type: "GET",
                dataType: "script"
            });
        } else {
            suggestionsBox.innerHTML = "";
        }
    });
});
