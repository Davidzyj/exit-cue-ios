(function () {
  const params = new URLSearchParams(window.location.search);
  const requested = params.get("lang");
  const browser = navigator.language || "en";
  const lang = requested || (browser.startsWith("zh") ? "zh-Hans" : browser.startsWith("ja") ? "ja" : "en");
  const fallback = "en";

  document.documentElement.lang = lang;
  document.querySelectorAll("[data-lang]").forEach((section) => {
    section.classList.toggle("active", section.getAttribute("data-lang") === lang);
  });

  if (!document.querySelector("[data-lang].active")) {
    document.querySelector(`[data-lang="${fallback}"]`)?.classList.add("active");
    document.documentElement.lang = fallback;
  }
})();
