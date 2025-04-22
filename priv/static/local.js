htmx.on("htmx:afterRequest", function (evt) {
  if (evt.detail.successful == true) {
    el = htmx.find('#addition');
    if (evt.target == el) {
      el.reset();
    }
  }
});

htmx.on("htmx:beforeRequest", function (evt) {
  el = htmx.find('#send-error');
  htmx.addClass(el, "hidden");
})

htmx.on("htmx:sendError", function (evt) {
  el = htmx.find('#send-error');
  el.innerHTML = "Unable to connect to server";
  htmx.removeClass(el, "hidden");
});

htmx.on("htmx:responseError", function (evt) {
  el = htmx.find('#send-error');
  error = evt.detail.xhr.response;
  el.innerHTML = error;
  htmx.removeClass(el, "hidden");
});
