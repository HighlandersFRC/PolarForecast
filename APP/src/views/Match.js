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
import { useHistory } from "react-router-dom";
import { alpha, styled } from "@mui/material/styles";
import React, { useEffect, useState } from "react";
import { getMatchDetails } from "api.js";
import { DataGrid, gridClasses } from "@mui/x-data-grid";
import { ThemeProvider, createTheme } from "@mui/material/styles";
import Typography from "@mui/material/Typography";
import Link from "@mui/material/Link";
import CircularProgress from "@mui/material/CircularProgress";
import EmojiEventsIcon from "@mui/icons-material/EmojiEvents";
import Box from "@mui/material/Box";
import "../assets/css/polar-css.css";
import { IconButton } from "@mui/material";
import ArrowLeftIcon from "@mui/icons-material/ArrowLeft";
import ArrowRightIcon from '@mui/icons-material/ArrowRight';

const Match = () => {
  const history = useHistory();

  const [loading, setLoading] = useState(true);
  const [data, setData] = useState([]);
  const [matchTitle, setMatchTitle] = useState(false);
  const [matchNumber, setMatchNumber] = useState();
  const [bluePrediction, setBluePrediction] = useState(false);
  const [blueResult, setBlueResult] = useState(false);
  const [redPrediction, setRedPrediction] = useState(false);
  const [redResult, setRedResult] = useState(false);
  const [redTitle, setRedTitle] = useState(false);
  const [blueRows, setBlueRows] = useState([]);
  const [redRows, setRedRows] = useState([]);
  const [blueWinner, setBlueWinner] = useState(false);
  const [redWinner, setRedWinner] = useState(false);
  const [columns, setColumns] = useState([
    {
      field: "team",
      headerName: "Team",
      sortable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
      renderCell: (params) => {
        const onClick = (e) => statisticsTeamOnClick(params.row);
        return (
          <div>
            <Link component="button" onClick={onClick} underline="always">
              {params.value}
            </Link>
          </div>
        );
      },
    },
    {
      field: "auto_score",
      headerName: "Auto",
      filterable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
    },
    {
      field: "auto_charge_station",
      headerName: "Auto CS",
      filterable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
      minWidth: 75,
    },
    {
      field: "teleop_score",
      headerName: "Teleop",
      filterable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
    },
    {
      field: "end_game",
      headerName: "End Game",
      filterable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
      minWidth: 100,
    },
    {
      field: "OPR",
      headerName: "OPR",
      filterable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.3,
    },
  ]);

  const statisticsTeamOnClick = (cellValues) => {
    history.push("team-" + cellValues.team);
  };

  const rightOnClick = (cellValues) => {
    console.log(matchNumber);
    // history.push("team-" + cellValues.team);
  };

  const matchInfoCallback = async (restData) => {
    setData(restData);
    let newRow = {};
    const blueAutoRows = [];
    let i = 0;
    let blueAutoScore = 0;
    let blueChargeStation = 0;
    let blueTeleop = 0;
    for (const team of restData?.blue_teams) {
      newRow = {
        key: i,
        team: team.key.replace("frc", ""),
        OPR: team.OPR.toFixed(1),
        auto_score: team.autoPoints.toFixed(1),
        auto_charge_station: team.autoChargeStation.toFixed(1),
        teleop_score: team.teleopPoints.toFixed(1),
        end_game: team.endgamePoints.toFixed(1),
      };
      blueAutoRows.push(newRow);
      i = i + 1;
      blueAutoScore = blueAutoScore + team.autoPoints;
      blueChargeStation = blueChargeStation + team.autoChargeStation;
      blueTeleop = blueTeleop + team.teleopPoints;
    }
    newRow = {
      key: 4,
      team: "",
      auto_score: blueAutoScore?.toFixed(1),
      auto_charge_station: blueChargeStation?.toFixed(1),
      teleop_score: blueTeleop?.toFixed(1),
      end_game: restData?.prediction.blue_endGame?.toFixed(1),
    };
    blueAutoRows.push(newRow);

    setBlueRows(blueAutoRows);

    const redAutoRows = [];
    i = 0;
    let redAutoScore = 0;
    let redChargeStation = 0;
    let redTeleop = 0;
    for (const team of restData?.red_teams) {
      newRow = {
        key: i,
        team: team.key.replace("frc", ""),
        OPR: team.OPR.toFixed(1),
        auto_score: team.autoPoints.toFixed(1),
        auto_charge_station: team.autoChargeStation.toFixed(1),
        teleop_score: team.teleopPoints.toFixed(1),
        end_game: team.endgamePoints.toFixed(1),
      };
      redAutoRows.push(newRow);
      i = i + 1;
      redAutoScore = redAutoScore + team.autoPoints;
      redChargeStation = redChargeStation + team.autoChargeStation;
      redTeleop = redTeleop + team.teleopPoints;
    }
    newRow = {
      key: 4,
      team: "",
      auto_score: redAutoScore?.toFixed(1),
      auto_charge_station: redChargeStation?.toFixed(1),
      teleop_score: redTeleop?.toFixed(1),
      end_game: restData?.prediction.red_endGame?.toFixed(1),
    };
    redAutoRows.push(newRow);
    setRedRows(redAutoRows);

    if (restData?.match.winning_alliance === "red") {
      setRedWinner(true);
    } else if (restData?.match.winning_alliance === "blue") {
      setBlueWinner(true);
    }

    let date = new Date();
    if (restData?.match["actual_time"]) {
      date = new Date(restData?.match.actual_time * 1000);
      setBlueResult(`${Math.round(restData?.match.score_breakdown.blue.totalPoints)} Points,  
      ${Math.round(restData?.match.score_breakdown.blue.rp)} RPs`);
      setRedResult(`${Math.round(restData?.match.score_breakdown.red.totalPoints)} Points,  
      ${Math.round(restData?.match.score_breakdown.red.rp)} RPs`);
    } else {
      date = new Date(restData?.match.predicted_time * 1000);
    }
    const timeOfDay = date.toLocaleTimeString([], { hour: "numeric", minute: "numeric" });
    setMatchTitle(`#${restData?.prediction?.match_number} - ${timeOfDay}`);
    setBluePrediction(`${Math.round(restData?.prediction?.blue_score)} Points,  
      ${Math.round(restData?.prediction?.blue_win_rp)} RPs`);
    setRedPrediction(`${Math.round(restData?.prediction?.red_score)} Points,  
      ${Math.round(restData?.prediction?.red_win_rp)} RPs`);
    setRedTitle(
      ": " +
        String(Math.round(restData?.prediction?.red_score)) +
        " Points, " +
        String(Math.round(restData?.prediction?.red_win_rp)) +
        " RPs"
    );

    setLoading(false);
  };

  useEffect(() => {
    const url = new URL(window.location.href);
    const params = url.pathname.split("/");
    const year = params[3];
    const eventKey = params[4];
    const match = params[5].split("-")[1];
    setMatchNumber(match);

    getMatchDetails(year, eventKey, match, matchInfoCallback);
  }, []);

  return (
    <>
      <ThemeProvider theme={darkTheme}>
        <div style={{ height: "calc(100vh - 132px)", width: "100%", overflow: "auto" }}>
          <Container>
            <Row>
              <div style={{ width: "100%" }}>
                <Card className="polar-box">
                  <CardHeader className="bg-transparent" style={{ textAlign: "center", display: "flex", justifyContent: "center", alignItems: "center" }}>
                      {/* {matchNumber.split("_").length } */}
                      {/* <IconButton>
                        <ArrowLeftIcon />
                      </IconButton> */}
                      <h1 className="text-white mb-0">Match {matchTitle}</h1>
                      {/* <IconButton>
                        <ArrowRightIcon 
                          onClick={rightOnClick}
                        />
                      </IconButton> */}
                  </CardHeader>
                </Card>
              </div>
            </Row>

            <Row>
              <div style={{ width: "100%" }}>
                <Card className="polar-box">
                  <CardHeader className="bg-transparent">
                    <h3 style={{ color: "#90caf9" }}>
                      {blueWinner && <EmojiEventsIcon />}Blue Alliance
                    </h3>
                    <h4 className="text-white mb-0">Prediction: {bluePrediction}</h4>
                    {blueResult && <h4 className="text-white mb-0">Result: {blueResult}</h4>}
                  </CardHeader>
                  <div style={{ height: "200px", width: "100%" }}>
                    {blueRows.length > 0 ? (
                      <StripedDataGrid
                        disableColumnMenu
                        rows={blueRows}
                        getRowId={(row) => {
                          return row.key;
                        }}
                        columns={columns}
                        hideFooter
                        pageSize={100}
                        rowsPerPageOptions={[100]}
                        rowHeight={30}
                        options={{ pagination: false }}
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
                          minHeight: "320px",
                        }}
                      >
                        <CircularProgress />
                      </Box>
                    )}
                  </div>
                </Card>
                <Card className="polar-box">
                  <CardHeader className="bg-transparent">
                    <h3 style={{ color: "#FF0000" }}>
                      {redWinner && <EmojiEventsIcon />}Red Alliance
                    </h3>
                    <h4 className="text-white mb-0">Prediction: {redPrediction}</h4>
                    {redResult && <h4 className="text-white mb-0">Result: {redResult}</h4>}
                  </CardHeader>
                  <div style={{ height: "200px", width: "100%" }}>
                    {redRows.length > 0 ? (
                      <StripedDataGrid
                        disableColumnMenu
                        rows={redRows}
                        getRowId={(row) => {
                          return row.key;
                        }}
                        columns={columns}
                        pageSize={100}
                        rowsPerPageOptions={[100]}
                        rowHeight={30}
                        hideFooter
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
                          minHeight: "320px",
                        }}
                      >
                        <CircularProgress />
                      </Box>
                    )}
                  </div>
                </Card>
              </div>
            </Row>
          </Container>
        </div>
      </ThemeProvider>
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

export default Match;
