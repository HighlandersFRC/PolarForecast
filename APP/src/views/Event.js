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
import { useMediaQuery, useTheme } from "@mui/material";
import { alpha, styled, ThemeProvider, createTheme } from "@mui/material/styles";
import AppBar from "@mui/material/AppBar";
import Tabs from "@mui/material/Tabs";
import Tab from "@mui/material/Tab";
import Typography from "@mui/material/Typography";
import Box from "@mui/material/Box";
import Header from "components/Headers/Header.js";
import React, { useEffect, useState } from "react";
import { getStatDescription, getRankings, getMatchPredictions, getSearchKeys } from "api.js";
import { DataGrid, gridClasses, GridToolbar } from "@mui/x-data-grid";
import { useHistory } from "react-router-dom";
import Stack from "@mui/material/Stack";
import Snowfall from "react-snowfall";
import CircularProgress from "@mui/material/CircularProgress";
import EmojiEventsIcon from "@mui/icons-material/EmojiEvents";
import BarChartWithSwitches from "../components/BarChartWithSwitches";
import Link from "@mui/material/Link";
import "../assets/css/polar-css.css";

const switchTheme = createTheme({
  palette: {
    primary: {
      main: "#4D9DE0",
    },
    secondary: {
      main: "#E15554",
    },
    tertiary: {
      main: "#7768AE",
    },
    quaternary: {
      main: "#3BB273",
    },
  },
});

const Tables = () => {
  const history = useHistory();
  const tabDict = ["rankings", "charts", "quals", "elims"];
  const theme = useTheme();
  const isDesktop = useMediaQuery(theme.breakpoints.up("md"));
  const [containerHeight, setContainerHeight] = useState(`calc(100vh - 200px)`);
  const [containerDivHeight, setContainerDivHeight] = useState(`calc(100vh - 250px)`);
  const [chartNumber, setChartNumber] = useState(32);
  const [statDescription, setStatDescription] = useState([]);
  const [tabIndex, setTabIndex] = useState(0);
  const [eventTitle, setEventTitle] = useState("");
  const [rankings, setRankings] = useState([]);
  const [qualPredictions, setQualPredictions] = useState([]);
  const [elimPredictions, setElimPredictions] = useState([]);
  const [showKeys, setShowKeys] = useState([]);
  const [statColumns, setStatColumns] = useState([]);
  const [matchPredictionColumns, setMatchPredictionColumns] = useState([
    {
      field: "match_number",
      headerName: "Match",
      sortable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
      renderCell: (params) => {
        const onClick = (e) => statisticsMatchOnClick(params.row);
        return (
          <Link component="button" onClick={onClick} underline="always">
            {params.value}
          </Link>
        );
      },
    },
    {
      field: "data_type",
      headerName: "Type",
      sortable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
    },
    {
      field: "blue_score",
      headerName: "Blue",
      sortable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
      renderCell: (params) => {
        let showTrophy = false;
        if ("blue_actual_score" in params.row) {
          showTrophy = true;
        }
        if (parseFloat(params.row.blue_score) > parseFloat(params.row.red_score)) {
          return (
            <Typography fontWeight="bold" color="primary">
              {showTrophy && <EmojiEventsIcon />} {params.value}
            </Typography>
          );
        } else {
          return <Typography color="#FFFFFF"> {params.value}</Typography>;
        }
      },
    },
    {
      field: "red_score",
      headerName: "Red",
      sortable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
      renderCell: (params) => {
        let showTrophy = false;
        if ("red_actual_score" in params.row) {
          showTrophy = true;
        }
        if (parseFloat(params.row.blue_score) < parseFloat(params.row.red_score)) {
          return (
            <Typography fontWeight="bold" color="#FF0000">
              {showTrophy && <EmojiEventsIcon />} {params.value}
            </Typography>
          );
        } else {
          return <Typography color="#FFFFFF"> {params.value}</Typography>;
        }
      },
    },
  ]);

  const statDescriptionCallback = async (data) => {
    const keys = [];
    const statColumns = [];
    statColumns.push({
      field: "id",
      headerName: "",
      filterable: false,
      renderCell: (index) => index.api.getRowIndexRelativeToVisibleRows(index.row.key) + 1,
      disableExport: true,
      flex: 0.1,
    });

    statColumns.push({
      field: "key",
      headerName: "Team",
      filterable: false,
      headerAlign: "center",
      align: "center",
      minWidth: 80,
      flex: 0.5,
      renderCell: (params) => {
        const onClick = (e) => statisticsTeamOnClick(params.row);
        return (
          <Link component="button" onClick={onClick} underline="always">
            {params.value}
          </Link>
        );
      },
    });

    statColumns.push({
      field: "OPR",
      headerName: "OPR",
      type: "number",
      sortable: true,
      headerAlign: "center",
      align: "center",
      minWidth: 80,
      flex: 0.5,
    });

    for (let i = 0; i < data.data.length; i++) {
      const stat = data.data[i];
      if (stat.report_stat && stat.stat_key !== "OPR") {
        keys.push(stat.stat_key);
        statColumns.push({
          field: stat.stat_key,
          headerName: stat.display_name,
          type: "number",
          sortable: true,
          headerAlign: "center",
          align: "center",
          minWidth: 80,
          flex: 0.5,
        });
      }
    }
    setShowKeys(keys);
    setStatDescription(data.data);
    setStatColumns(statColumns);
  };

  const statisticsTeamOnClick = (cellValues) => {
    const url = new URL(window.location.href);
    const eventKey = url.pathname.split("/")[4];
    history.push(eventKey + "/team-" + cellValues.key);
  };

  const statisticsMatchOnClick = (cellValues) => {
    const url = new URL(window.location.href);
    const eventKey = url.pathname.split("/")[4];
    history.push(eventKey + "/match-" + cellValues.key);
  };

  const rankingsCallback = async (data) => {
    data.data = data.data.filter((obj) => {
      if (obj.key) {
        return true;
      }
    });
    let oprList = [];

    for (const team of data?.data) {
      if (team.key) {
        team.key = team.key.replace("frc", "");
      }
      oprList.push(team.OPR);
      for (const [key, value] of Object.entries(team)) {
        if (
          typeof value === "number" &&
          key.toLowerCase() !== "rank" &&
          key !== "expectedRanking" &&
          key.toLowerCase() !== "schedule"
        ) {
          team[key] = team[key]?.toFixed(1);
        } else {
          team[key] = Number(team[key]);
        }
      }
      team["elementsLow"] = (Number(team.autoLow) + Number(team.teleopLow)).toFixed(1);
      team["elementsMid"] = (
        Number(team.autoMidCones) +
        Number(team.autoMidCubes) +
        Number(team.teleopMidCones) +
        Number(team.teleopMidCubes)
      ).toFixed(1);
      team["elementsHigh"] = (
        Number(team.autoHighCones) +
        Number(team.autoHighCubes) +
        Number(team.teleopHighCones) +
        Number(team.teleopHighCubes)
      ).toFixed(1);
    }
    const sortedData = [...data.data].sort((a, b) => Number(b.OPR) - Number(a.OPR));

    setRankings(sortedData);
  };

  const predictionsCallback = async (data) => {
    const qual_rows = [];
    const sf_rows = [];
    const f_rows = [];
    for (const match of data.data) {
      if (match.comp_level === "qm") {
        for (const [key, value] of Object.entries(match)) {
          if (typeof value === "number" && key.toLowerCase() !== "match_number") {
            match[key] = match[key]?.toFixed(0);
          }
        }
        if ("blue_actual_score" in match) {
          match.data_type = "Result";
          match.blue_score = match.blue_actual_score;
          match.red_score = match.red_actual_score;
        } else {
          match.data_type = "Predicted";
        }
        match.sort = Number(match.match_number);
        match.match_number = "QM-" + match.match_number;
        qual_rows.push(match);
      } else if (match.comp_level === "sf") {
        for (const [key, value] of Object.entries(match)) {
          if (typeof value === "number" && key.toLowerCase() !== "match_number") {
            match[key] = match[key]?.toFixed(0);
          }
        }
        if ("blue_actual_score" in match) {
          match.data_type = "Result";
          match.blue_score = match.blue_actual_score;
          match.red_score = match.red_actual_score;
        } else {
          match.data_type = "Predicted";
        }
        match.match_key = Number(match.set_number).toFixed(0);
        match.match_number =
          match.comp_level.toUpperCase() + "-" + Number(match.set_number).toFixed(0);
        sf_rows.push(match);
      } else if (match.comp_level === "f") {
        for (const [key, value] of Object.entries(match)) {
          if (typeof value === "number" && key.toLowerCase() !== "match_number") {
            match[key] = match[key]?.toFixed(0);
          }
        }
        if ("blue_actual_score" in match) {
          match.data_type = "Result";
          match.blue_score = match.blue_actual_score;
          match.red_score = match.red_actual_score;
        } else {
          match.data_type = "Predicted";
        }
        match.match_key = match.match_number;
        match.match_number =
          match.comp_level.toUpperCase() + "-" + Number(match.match_number).toFixed(0);
        f_rows.push(match);
      }
    }
    qual_rows.sort(function (a, b) {
      return a.sort - b.sort;
    });
    sf_rows.sort(function (a, b) {
      return a.match_key - b.match_key;
    });

    f_rows.sort(function (a, b) {
      return a.match_key - b.match_key;
    });

    const elim_rows = sf_rows.concat(f_rows);

    setQualPredictions(qual_rows);
    setElimPredictions(elim_rows);
  };

  const searchKeysCallback = async (data) => {
    const url = new URL(window.location.href);
    const eventName = url.pathname.split("/")[3] + url.pathname.split("/")[4];
    let array = [];
    if (data?.data?.length > 0) {
      array = [...data.data];
    } else if (data?.length > 0) {
      array = [...data];
    }
    for (let i = 0; i < array.length; i++) {
      if (array[i]?.key === eventName) {
        setEventTitle(array[i]?.display.split("[")[0]);
      }
    }
  };

  useEffect(() => {
    const url = new URL(window.location.href);
    const params = url.pathname.split("/");
    const year = params[3];
    const eventKey = params[4];

    if (window.location.hash.length > 0) {
      setTabIndex(tabDict.indexOf(String(window.location.hash.split("#")[1])));
    }

    getStatDescription(year, eventKey, statDescriptionCallback);
    getRankings(year, eventKey, rankingsCallback);
    getMatchPredictions(year, eventKey, predictionsCallback);
    getSearchKeys(searchKeysCallback);
  }, []);

  useEffect(() => {
    if (!isDesktop) {
      setContainerHeight(`calc(100vh - 255px)`);
      setContainerDivHeight(`calc(100vh - 185px)`);
      setChartNumber(20);
    } else {
      setContainerHeight(`calc(100vh - 210px)`);
      setContainerDivHeight(`calc(100vh - 140px)`);
      setChartNumber(50);
    }
  }, [isDesktop]);

  function TabPanel(props) {
    const { children, value, index, ...other } = props;
    return (
      <div
        role="tabpanel"
        hidden={value !== index}
        id={`full-width-tabpanel-${index}`}
        aria-labelledby={`full-width-tab-${index}`}
        {...other}
      >
        {value === index && (
          <Box sx={{ display: "flex", flexDirection: "column", height: "calc(100vh - 210px)" }}>
            <ThemeProvider theme={darkTheme}>
              <Container>
                <Row>
                  <div style={{ height: containerHeight, width: "100%" }}>{children}</div>
                </Row>
              </Container>
            </ThemeProvider>
          </Box>
        )}
      </div>
    );
  }

  function a11yProps(index) {
    return {
      id: `full-width-tab-${index}`,
      "aria-controls": `full-width-tabpanel-${index}`,
    };
  }

  const handleChange = (event, newValue) => {
    history.push({ hash: tabDict[newValue] });
    setTabIndex(newValue);
  };

  return (
    <>
      <Header />
      <AppBar position="static">
        <Tabs
          value={tabIndex}
          onChange={handleChange}
          indicatorColor="secondary"
          textColor="inherit"
          variant="fullWidth"
          aria-label="full width tabs"
        >
          <Tab label="Rankings" {...a11yProps(0)} />
          <Tab label="Charts" {...a11yProps(1)} />
          {qualPredictions.length > 0 && <Tab label="Quals" {...a11yProps(2)} />}
          {elimPredictions.length > 0 && <Tab label="Elims" {...a11yProps(3)} />}
          {/* <Tab label="Polar Power" {...a11yProps(2)} /> */}
        </Tabs>
      </AppBar>
      <div style={{ height: containerDivHeight, width: "100%", overflow: "auto" }}>
        <TabPanel value={tabIndex} index={0} dir={darkTheme.direction}>
          <Card className="polar-box">
            <CardHeader className="bg-transparent">
              <h3 className="text-white mb-0">Event Rankings - {eventTitle}</h3>
            </CardHeader>
            <div style={{ height: containerHeight, width: "100%" }}>
              {rankings.length > 0 ? (
                <StripedDataGrid
                  initialState={{
                    sorting: {
                      sortModel: [{ field: "OPR", sort: "desc" }],
                      pagination: { paginationModel: { pageSize: 50 } },
                    },
                  }}
                  disableColumnMenu
                  sortingOrder={["desc", "asc"]}
                  rows={rankings}
                  getRowId={(row) => {
                    return row.key;
                  }}
                  columns={statColumns}
                  pageSize={100}
                  rowsPerPageOptions={[100]}
                  rowHeight={35}
                  slots={{ toolbar: GridToolbar }}
                  slotProps={{
                    toolbar: {
                      showQuickFilter: true,
                      quickFilterProps: { debounceMs: 500 },
                    },
                  }}
                  disableColumnFilter={!isDesktop}
                  disableColumnSelector={!isDesktop}
                  disableDensitySelector={!isDesktop}
                  disableExportSelector={!isDesktop}
                  sx={{
                    mx: 0.5,
                    border: 0,
                    borderColor: "white",
                    "& .MuiDataGrid-cell:hover": {
                      color: "white",
                    },
                  }}
                  getRowClassName={(params) =>
                    params.indexRelativeToCurrentPage % 2 === 0 ? "even" : "odd"
                  }
                />
              ) : (
                <Box
                  sx={{
                    display: "flex",
                    justifyContent: "center",
                    alignItems: "center",
                    minHeight: "calc(100vh - 300px)",
                  }}
                >
                  <CircularProgress />
                </Box>
              )}
            </div>
          </Card>
        </TabPanel>
        <TabPanel value={tabIndex} index={1} dir={darkTheme.direction}>
          <div style={{ height: containerDivHeight, width: "100%" }}>
            <ThemeProvider theme={switchTheme}>
              <BarChartWithSwitches
                data={rankings}
                number={chartNumber}
                startingFields={[
                  { index: 0, name: "Auto", key: "autoPoints", enabled: true },
                  { index: 1, name: "Teleop", key: "teleopPoints", enabled: true },
                  { index: 2, name: "Links", key: "linkPoints", enabled: true },
                  { index: 3, name: "End Game", key: "endgamePoints", enabled: true },
                ]}
              />
              <br />
              <BarChartWithSwitches
                data={rankings}
                number={chartNumber}
                startingFields={[
                  { index: 0, name: "Teleop Elements", key: "teleopElementsScored", enabled: true },
                  { index: 1, name: "Auto Elements", key: "autoElementsScored", enabled: true },
                ]}
              />
              <br />
              <BarChartWithSwitches
                data={rankings}
                number={chartNumber}
                startingFields={[
                  { index: 0, name: "Low", key: "elementsLow", enabled: true },
                  { index: 1, name: "Middle", key: "elementsMid", enabled: true },
                  { index: 2, name: "High", key: "elementsHigh", enabled: true },
                ]}
              />
            </ThemeProvider>
          </div>
        </TabPanel>
        <TabPanel value={tabIndex} index={2} dir={darkTheme.direction}>
          <div style={{ height: containerHeight, width: "100%" }}>
            <Card className="polar-box">
              <CardHeader className="bg-transparent">
                <h3 className="text-white mb-0">Qualifications - {eventTitle}</h3>
              </CardHeader>
              <div style={{ height: containerHeight, width: "100%" }}>
                <StripedDataGrid
                  disableColumnMenu
                  rows={qualPredictions}
                  getRowId={(row) => {
                    return row.key;
                  }}
                  columns={matchPredictionColumns}
                  pageSize={100}
                  rowsPerPageOptions={[100]}
                  rowHeight={35}
                  disableExtendRowFullWidth={true}
                  sx={{
                    boxShadow: 2,
                    border: 0,
                    borderColor: "white",
                    "& .MuiDataGrid-cell:hover": {
                      color: "white",
                    },
                  }}
                  components={{
                    NoRowsOverlay: () => (
                      <Stack height="100%" alignItems="center" justifyContent="center">
                        No Match Data
                      </Stack>
                    ),
                  }}
                  getRowClassName={(params) =>
                    params.indexRelativeToCurrentPage % 2 === 0 ? "even" : "odd"
                  }
                />
              </div>
            </Card>
          </div>
        </TabPanel>
        <TabPanel value={tabIndex} index={3} dir={darkTheme.direction}>
          <Card className="polar-box">
            <CardHeader className="bg-transparent">
              <h3 className="text-white mb-0">Eliminations - {eventTitle}</h3>
            </CardHeader>
            <div style={{ height: containerHeight, width: "100%" }}>
              <StripedDataGrid
                disableColumnMenu
                rows={elimPredictions}
                getRowId={(row) => {
                  return row.key;
                }}
                columns={matchPredictionColumns}
                pageSize={100}
                rowsPerPageOptions={[100]}
                rowHeight={35}
                disableExtendRowFullWidth={true}
                sx={{
                  boxShadow: 2,
                  border: 0,
                  borderColor: "white",
                  "& .MuiDataGrid-cell:hover": {
                    color: "white",
                  },
                }}
                components={{
                  NoRowsOverlay: () => (
                    <Stack height="100%" alignItems="center" justifyContent="center">
                      No Match Data
                    </Stack>
                  ),
                }}
                getRowClassName={(params) =>
                  params.indexRelativeToCurrentPage % 2 === 0 ? "even" : "odd"
                }
              />
            </div>
          </Card>
        </TabPanel>
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

export default Tables;
