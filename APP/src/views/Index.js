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
import Chart from "chart.js";
import { Card, CardHeader, Container, Row } from "reactstrap";
import { useMediaQuery, useTheme } from "@mui/material";
import { alpha, styled } from "@mui/material/styles";
import { chartOptions, parseOptions } from "variables/charts.js";
import Header from "components/Headers/Header.js";
import Snowfall from "react-snowfall";
import React, { useEffect, useState } from "react";
import { ThemeProvider, createTheme } from "@mui/material/styles";
import { DataGrid, gridClasses } from "@mui/x-data-grid";
import MatchDataScanner from "components/MatchDataScanner";

const Index = () => {
  const theme = useTheme();
  const isDesktop = useMediaQuery(theme.breakpoints.up("md"));
  const [containerHeight, setContainerHeight] = useState(`calc(100vh - 170px)`);
  const [leaderboardRows, setLeaderboardRows] = useState([]);
  const [leaderboardColumns, setLeaderboardColumns] = useState([
    {
      field: "id",
      headerName: "",
      filterable: false,
      sortable: false,
      renderCell: (index) => index.api.getRowIndexRelativeToVisibleRows(index.row.key) + 1,
      disableExport: true,
      GridColDef: "center",
      flex: 0.1,
    },
    {
      field: "key",
      headerName: "Team",
      headerAlign: "center",
      align: "center",
      minWidth: 75,
      flex: 0.5,
    },
    {
      field: "OPR",
      headerName: "OPR",
      disableExport: true,
      headerAlign: "center",
      align: "center",
      minWidth: 75,
      flex: 0.25,
    },
    {
      field: "global_ranking",
      headerName: "OPR Rank",
      disableExport: true,
      headerAlign: "center",
      align: "center",
      minWidth: 100,
      flex: 0.25,
    },
    {
      field: "autoPoints",
      headerName: "Auto",
      disableExport: true,
      headerAlign: "center",
      align: "center",
      minWidth: 50,
      flex: 0.5,
    },
    {
      field: "teleopPoints",
      headerName: "Teleop",
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
    },
    {
      field: "endgamePoints",
      headerName: "EndGame",
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
    },
  ]);

  if (window.Chart) {
    parseOptions(Chart, chartOptions());
  }

  useEffect(() => {
    const now = new Date();
    const currentYear = now.getFullYear();
    if (!isDesktop) {
      setContainerHeight(`calc(100vh - 180px)`);
    } else {
      setContainerHeight(`calc(100vh - 170px)`)
    }
  }, [isDesktop]);

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
                    <h3 className="text-white mb-0">QR Reader</h3>
                  </CardHeader>
                  <div style={{ display: 'flex', flexDirection: 'column', marginTop: '0px', justifyContent:'center', alignItems:'center', minHeight:'70vh'}}>
                    <MatchDataScanner/>
                  </div>
                </Card>
              </div>
            </Row>
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

export default Index;
