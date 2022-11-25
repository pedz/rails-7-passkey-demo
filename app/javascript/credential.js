import * as WebAuthnJSON from "@github/webauthn-json/browser-ponyfill"
// import { showMessage } from "messenger";

function getCSRFToken() {
  var CSRFSelector = document.querySelector('meta[name="csrf-token"]')
  if (CSRFSelector) {
    return CSRFSelector.getAttribute("content")
  } else {
    return null
  }
}

function displayError(message) {
  const ele = document.querySelector('#message-box');
  const event = new CustomEvent('msg', { detail: { message: message}});
  ele.dispatchEvent(event);
  console.log("event sent");
}

function callback(url, body) {
  console.log("in callback", url);
  fetch(url, {
    method: "POST",
    body: JSON.stringify(body),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "X-CSRF-Token": getCSRFToken()
    },
    credentials: 'same-origin'
  }).then(function(response) {
    if (response.ok) {
      window.location.replace("/")
    } else if (response.status < 500) {
      // response.text().then(showMessage);
      console.log("response not ok");
      response.text().then((text) => { displayError(text) });
    } else {
      showMessage("Sorry, something wrong happened.");
    }
  });
}

function create(callbackUrl, credentialOptions) {
  console.log("create", callbackUrl);
  const options = WebAuthnJSON.parseCreationOptionsFromJSON({ "publicKey": credentialOptions })
  console.log("options");
  WebAuthnJSON.create(options).then((response) => {
    callback(callbackUrl, response);
  }).catch(function(error) {
    console.log("create error", error);
  });

  console.log("Creating new public key credential...");
}

function get(credentialOptions) {
  WebAuthnJSON.get({ "publicKey": credentialOptions }).then(function(credential) {
    callback("/session/callback", credential);
  }).catch(function(error) {
    showMessage(error);
  });

  console.log("Getting public key credential...");
}

export { create, get }
