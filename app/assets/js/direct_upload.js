// Direct uploads (hanami-attachments).
//
// Enhances file inputs rendered by `attachment_field` for uploaders with `direct_uploads`:
//
//   <input type="file" data-direct-upload="/uploads/clip/presign" data-direct-upload-field="clip[cached_video]">
//
// When a file is picked, it's uploaded straight to storage (or to the app, when files are stored
// locally), its data goes into the hidden field, and the file input stops being submitted, so the
// form post itself is small. Without JavaScript the form still works as a normal upload.
//
// Events, dispatched on the file input (they bubble):
//
//   direct-upload:start     detail: {file}
//   direct-upload:progress  detail: {file, loaded, total}
//   direct-upload:done      detail: {file, data}
//   direct-upload:error     detail: {file, errors}
//
// While uploads are in flight, the form gets a `data-direct-upload-pending` attribute, its submit
// buttons are disabled, and submitting it is blocked (this works with Turbo too).

const SELECTOR = "input[type=file][data-direct-upload]";
const pending = new WeakMap();

function csrfToken(form) {
  const field = form && form.querySelector("input[name=_csrf_token]");
  if (field) return field.value;
  const meta = document.querySelector("meta[name=csrf-token]");
  return meta ? meta.content : null;
}

function dispatch(input, name, detail) {
  input.dispatchEvent(new CustomEvent(`direct-upload:${name}`, { bubbles: true, detail }));
}

function send(method, url, body, headers, onProgress) {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    xhr.open(method, url);
    xhr.setRequestHeader("Accept", "application/json");
    for (const [name, value] of Object.entries(headers || {})) xhr.setRequestHeader(name, value);
    if (onProgress) {
      xhr.upload.addEventListener("progress", (event) => {
        if (event.lengthComputable) onProgress(event.loaded, event.total);
      });
    }
    xhr.addEventListener("load", () => resolve(xhr));
    xhr.addEventListener("error", () => reject(["could not be uploaded (network error)"]));
    xhr.send(body);
  });
}

function json(xhr) {
  try {
    return JSON.parse(xhr.responseText);
  } catch {
    return {};
  }
}

function failed(xhr) {
  return json(xhr).errors || [`could not be uploaded (${xhr.status})`];
}

async function upload(input, file) {
  const token = csrfToken(input.form);
  const appHeaders = token ? { "X-CSRF-Token": token } : {};

  const params = new URLSearchParams({ filename: file.name, type: file.type, size: String(file.size) });
  const presignXhr = await send("POST", input.dataset.directUpload, params, appHeaders);
  if (presignXhr.status !== 200) throw failed(presignXhr);
  const presign = json(presignXhr);

  // A presign with `file` goes to external storage: send only what it asks for. Without one, the
  // upload goes to the app itself, which needs the CSRF token.
  const external = Boolean(presign.file);
  let body;

  if (presign.method.toLowerCase() === "put") {
    body = file;
  } else {
    body = new FormData();
    for (const [name, value] of Object.entries(presign.fields || {})) body.append(name, value);
    body.append("file", file);
  }

  const headers = external ? presign.headers : { ...appHeaders, ...presign.headers };
  const progress = (loaded, total) => dispatch(input, "progress", { file, loaded, total });
  const uploadXhr = await send(presign.method.toUpperCase(), presign.url, body, headers, progress);
  if (uploadXhr.status < 200 || uploadXhr.status >= 300) throw failed(uploadXhr);

  return external ? presign.file : json(uploadXhr).file;
}

function track(form, delta) {
  if (!form) return;
  const count = (pending.get(form) || 0) + delta;
  pending.set(form, count);
  form.toggleAttribute("data-direct-upload-pending", count > 0);
  for (const button of form.querySelectorAll("button[type=submit], input[type=submit], button:not([type])")) {
    button.disabled = count > 0;
  }
}

document.addEventListener("change", async (event) => {
  const input = event.target;
  if (!(input instanceof HTMLInputElement) || !input.matches(SELECTOR)) return;

  const file = input.files && input.files[0];
  if (!file) return;

  const form = input.form;
  const fieldName = input.dataset.directUploadField;
  const field = form && fieldName ? form.querySelector(`input[type=hidden][name="${CSS.escape(fieldName)}"]`) : null;

  // Keep the chosen file visible, but don't submit its bytes again with the form.
  if (input.name) input.dataset.directUploadName = input.name;
  input.removeAttribute("name");

  track(form, 1);
  dispatch(input, "start", { file });

  try {
    const data = await upload(input, file);
    if (field) field.value = JSON.stringify(data);
    dispatch(input, "done", { file, data });
  } catch (errors) {
    // Fall back to a normal upload with the form.
    if (input.dataset.directUploadName) input.name = input.dataset.directUploadName;
    dispatch(input, "error", { file, errors: Array.isArray(errors) ? errors : [String(errors)] });
  } finally {
    track(form, -1);
  }
});

document.addEventListener(
  "submit",
  (event) => {
    if ((pending.get(event.target) || 0) > 0) {
      event.preventDefault();
      event.stopImmediatePropagation();
    }
  },
  true
);
