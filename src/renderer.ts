import Gateway from "./gateway";

console.log('renderer');

const copyButton = document.createElement('button');
copyButton.textContent = 'Get Clipboard';
document.body.appendChild(copyButton);

const getAllApplicationsButton = document.createElement('button');
getAllApplicationsButton.textContent = 'Get All Applications';
document.body.appendChild(getAllApplicationsButton);

const getScreenshotButton = document.createElement('button');
getScreenshotButton.textContent = 'Get Screenshot';
document.body.appendChild(getScreenshotButton);

const gateway = new Gateway();
// Add click event listener
copyButton.addEventListener('click', async () => {
    gateway.send({ method: "clipboard.get", data: null });
});

getAllApplicationsButton.addEventListener('click', async () => {
    gateway.send({ method: "accessibility.get_all_applications", data: null });
});

getScreenshotButton.addEventListener('click', async () => {
    gateway.send({ method: "screenshot.take", data: null });
});