import { Controller } from "@hotwired/stimulus"
import * as Credential from "credential";

export default class extends Controller {
  connect() {
    console.log("connect");
  }
  
  submit(event) {
    console.log("click", event);
    event.preventDefault();
    
    const headers = new Headers();
    headers.append('Accept', 'image/jpeg');
    const action = event.target.action;
    const options = {
      method: event.target.method,
      headers: headers,
      body: new FormData(event.target)
    };
    
    fetch(action, options).then((response) => {
      if (response.ok) {
        ok(response);
      } else {
        err(response);
      }
    });
    
    function ok(response) {
      response.json().then((data) => {
        console.log("data", data);
        const { callback_url, create_options } = data;
        console.log("callback_url", callback_url);
        console.log("create_options", create_options);
        
        if (create_options["user"]) {
          const xxx = encodeURI(callback_url);
          console.log("xxx", xxx)
          Credential.create(xxx, create_options);
        }
      });
    }
    
    function err(response) {
      console.log("Error");
    }
  }
}
