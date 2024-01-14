/*!

=========================================================
* Argon Dashboard React - v1.2.2
=========================================================

* Product Page: https://www.creative-tim.com/product/argon-dashboard-react
* Copyright 2022 Creative Tim (https://www.creative-tim.com)
* Licensed under MIT (https://github.com/creativetimofficial/argon-dashboard-react/blob/master/LICENSE.md)

* Coded by Creative Tim

=========================================================

* The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

*/
import React from "react";
import ReactDOM from "react-dom"; // Gets built in github, but fails in deployment
import { BrowserRouter, Route, Switch, Redirect } from "react-router-dom";

import "assets/plugins/nucleo/css/nucleo.css";
import "@fortawesome/fontawesome-free/css/all.min.css";
import "assets/scss/argon-dashboard-react.scss";
import DataLayout from "layouts/Data.js";

ReactDOM.render(
  <BrowserRouter>
    <Switch>
      <Route path="/data" render={(props) => <DataLayout {...props} />} />
      <Redirect from="/" to="/data/index" />
    </Switch>
  </BrowserRouter>,
  document.getElementById("root")
);
