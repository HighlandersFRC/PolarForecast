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
import { Card, CardHeader, Container, Row } from "reactstrap";
import { alpha, styled } from "@mui/material/styles";
import Header from "components/Headers/Header.js";
import Snowfall from "react-snowfall";
import React, { useEffect, useState } from "react";
import { ThemeProvider, createTheme } from "@mui/material/styles";
import { DataGrid, gridClasses, GridToolbar } from "@mui/x-data-grid";
import ImageUpload from "components/ImageUpload";
import CameraCapture from "components/CameraCapture";
import { postTeamPictures } from "api";
import { AppBar, Button } from "@mui/material";
import { useHistory } from "react-router-dom/cjs/react-router-dom.min";
import { getToken, login } from 'api';

const PitImages = () => {
  const [containerHeight, setContainerHeight] = useState(`calc(100vh - 200px)`);
  const history = useHistory()
  const url = new URL(window.location.href);
  const serverPath = url.pathname.split("/")[0];
  const [token, setToken] = useState(getToken());
  let eventName = url.pathname.split("/")[3] + url.pathname.split("/")[4];
  let year = url.pathname.split("/")[3]
  let eventCode = url.pathname.split("/")[4]
  let team = url.pathname.split("/")[5].replace("team-", "")
  if (token) {
    return (
      <>
        <Header />
        <div style={{ height: containerHeight, width: "100%" }}>
          <ThemeProvider theme={darkTheme}>
            <Container>
              <Row>
                <div style={{ height: containerHeight, width: "100%" }}>
                  <Card className="polar-box">
                    <CardHeader className="bg-transparent">
                      <h1 className="text-white mb-0">Pictures - {team}</h1>
                    </CardHeader>
                    <div style={{ width: "100%" }}>
                      <CameraCapture />
                    </div>
                  </Card>
                </div>
              </Row>
            </Container>
          </ThemeProvider>
          <Snowfall
            snowflakeCount={50}
            style={{
              position: "fixed",
              width: "100vw",
              height: "100vh",
            }}
          ></Snowfall>
        </div>
      </>
    );
  } else {
    return (
      <>
        <Header />
        <div style={{ height: containerHeight, width: "100%" }}>
          <ThemeProvider theme={darkTheme}>
            <Container>
              <Row></Row>
              <Card className="polar-box">
                <CardHeader className="bg-transparent">
                  <h1 className="text-white mb-0">Pictures - {team}</h1>
                </CardHeader>
                <div style={{ width: "100%" }}>
                  <form style={{ display: 'flex', flexDirection: 'column', gap: '16px', padding: '16px' }}>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                      <h1 className="text-white mb-0">Login Required</h1>
                      <br></br>
                      <Button fullwidth={true} variant="contained" onClick={() => setToken(login(url))}>Login</Button>
                    </div>
                  </form>
                </div>
              </Card>
            </Container>
          </ThemeProvider>
        </div>
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
  }
};

const darkTheme = createTheme({
  palette: {
    mode: "dark",
  },
});



export default PitImages;