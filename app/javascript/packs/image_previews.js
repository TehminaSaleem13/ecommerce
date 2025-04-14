// app/javascript/packs/image_previews.js
document.addEventListener('DOMContentLoaded', function () {
    const addImagesInput = document.getElementById('add-images-input');
    const imagePreviews = document.getElementById('image-previews');

    addImagesInput.addEventListener('change', function (event) {
        imagePreviews.innerHTML = ''; // Clear previous previews
        const files = event.target.files;

        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            const reader = new FileReader();

            reader.onload = function (e) {
                const img = document.createElement('img');
                img.src = e.target.result;
                img.style.width = '100px';
                img.style.height = '100px';
                img.style.marginRight = '10px';

                const removeButton = document.createElement('button');
                removeButton.textContent = 'Remove';
                removeButton.addEventListener('click', function () {
                    const dt = new DataTransfer();
                    const newFiles = Array.from(addImagesInput.files).filter(f => f !== file);
                    newFiles.forEach(f => dt.items.add(f));
                    addImagesInput.files = dt.files;
                    imagePreviews.removeChild(imgContainer);
                });

                const imgContainer = document.createElement('div');
                imgContainer.classList.add('image-preview');
                imgContainer.appendChild(img);
                imgContainer.appendChild(removeButton);

                imagePreviews.appendChild(imgContainer);
            };

            reader.readAsDataURL(file);
        }
    });
});
