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
import { AppBar } from "@mui/material";

const PitImages = () => {
  const [containerHeight, setContainerHeight] = useState(`calc(100vh - 200px)`);
  const [containerDivHeight, setContainerDivHeight] = useState(`calc(100vh - 250px)`);
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
                    <h3 className="text-white mb-0">Picture</h3>
                  </CardHeader>
                    <div style={{ width: "100%" }}>
                      <CameraCapture />
                    </div>
                </Card>
              </div>
            </Row>
          </Container>
        </ThemeProvider>
      </div>
    </>
  );
};

const darkTheme = createTheme({
  palette: {
    mode: "dark",
  },
});

const ODD_OPACITY = 0.2;

const StripedDataGrid = styled(DataGrid)(({ theme }) => ({
  [`& .${gridClasses.row}.even`]: {
    backgroundColor: alpha(theme.palette.primary.main, ODD_OPACITY),
    "&:hover, &.Mui-hovered": {
      backgroundColor: alpha("#78829c", ODD_OPACITY),
      "@media (hover: none)": {
        backgroundColor: "transparent",
      },
    },
    "&.Mui-selected": {
      backgroundColor: alpha(
        theme.palette.primary.main,
        ODD_OPACITY + theme.palette.action.selectedOpacity
      ),
      "&:hover, &.Mui-hovered": {
        backgroundColor: alpha(
          theme.palette.primary.main,
          ODD_OPACITY + theme.palette.action.selectedOpacity + theme.palette.action.hoverOpacity
        ),
        // Reset on touch devices, it doesn't add specificity
        "@media (hover: none)": {
          backgroundColor: alpha(
            theme.palette.primary.main,
            ODD_OPACITY + theme.palette.action.selectedOpacity
          ),
        },
      },
    },
  },
}));

export default PitImages;