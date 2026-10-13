// Shows progress for direct uploads, using hanami-attachments' events. Any file input with a
// sibling <progress data-upload-progress> and <small data-upload-status> gets it.
//
// (It's a module rather than an inline script because Hanami's default Content-Security-Policy
// only allows scripts from the app's own origin.)

function parts(input) {
  const container = input.closest("p") || input.parentElement;
  return {
    progress: container.querySelector("[data-upload-progress]"),
    status: container.querySelector("[data-upload-status]"),
  };
}

document.addEventListener("direct-upload:start", ({ target }) => {
  const { progress, status } = parts(target);
  if (progress) Object.assign(progress, { hidden: false, value: 0 });
  if (status) status.textContent = "Uploading…";
});

document.addEventListener("direct-upload:progress", ({ target, detail }) => {
  const { progress } = parts(target);
  if (progress) progress.value = Math.round((detail.loaded / detail.total) * 100);
});

document.addEventListener("direct-upload:done", ({ target }) => {
  const { progress, status } = parts(target);
  if (progress) progress.value = 100;
  if (status) status.textContent = "Uploaded. Add a title and save.";
});

document.addEventListener("direct-upload:error", ({ target, detail }) => {
  const { progress, status } = parts(target);
  if (progress) progress.hidden = true;
  if (status) status.textContent = `Video ${detail.errors.join(", ")}.`;
});
