document.addEventListener("DOMContentLoaded", () => {
    document.body.addEventListener("click", (e) => {
        if (e.target.matches(".edit-review-link")) {
            e.preventDefault();
            const reviewId = e.target.dataset.reviewId;
            const form = document.querySelector(`#edit-form-${reviewId}`);
            form.style.display = form.style.display === "none" ? "block" : "none";
        }

        if (e.target.matches(".cancel-edit-link")) {
            e.preventDefault();
            e.target.closest(".edit-review-form").style.display = "none";
        }
    });
});
