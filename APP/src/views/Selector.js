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
// reactstrap components

// core components
import Header from "components/Headers/Header.js";
import React, { useEffect } from "react";
import Team from "./Team.js";
import Match from "./Match.js";
import Snowfall from "react-snowfall";

const Selector = () => {
  const [type, setType] = React.useState("");
  const [event, setEvent] = React.useState("");

  useEffect(() => {
    const url = new URL(window.location.href);
    const path = url.pathname.split("/");
    const urlType = path[5].split("-")[0];
    if (type !== urlType) {
      setType(urlType);
    }
    setEvent(path[4]);
  }, [window.location.href]);

  return (
    <>
      <Header />

      {type === "team" && <Team />}
      {type === "match" && <Match />}
      <Snowfall
        snowflakeCount={50}
        style={{
          position: "fixed",
          width: "100vw",
          height: "100vh",
        }}
      ></Snowfall>
    </>
  );
};

export default Selector;
