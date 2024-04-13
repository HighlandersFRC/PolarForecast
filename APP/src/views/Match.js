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
import DrawingCanvas from "components/WhiteBoard";
import { AppBar, Dialog, DialogContent, DialogTitle, ImageList, ImageListItem, Tab, Tabs } from "@mui/material";
import { getTeamPictures } from "api";
import { getTeamScoutingData } from "api";
import AutoDisplay from "components/AutosDisplay";
import { Assignment, PrecisionManufacturing } from "@mui/icons-material";
import PitScoutingForm from "components/Scouting/PitScoutingForm";

const Match = () => {
  const history = useHistory();
  const url = new URL(window.location.href);
  const params = url.toString().split("/")
  const tabDict = ["stats", "autos-red", "autos-blue"];
  const year = params[5];
  const eventKey = params[6];
  const serverPath = url.pathname.split("/")[0];
  const [value, setValue] = React.useState(0);
  const [tabIndex, setTabIndex] = useState(0);
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
  const [blueScouting, setBlueScouting] = useState([[], [], []])
  const [pictures, setPictures] = React.useState([]);
  const [redWinner, setRedWinner] = useState(false);
  const [redScouting, setRedScouting] = useState([[], [], []])
  const [columns, setColumns] = useState([
    {
      field: "team",
      headerName: "Team",
      sortable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
      minWidth: 65,
      renderCell: (params) => {
        const onClick = () => statisticsTeamOnClick(params.row);
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
      field: "details",
      headerName: "Pit",
      sortable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.75,
      minWidth: 75,
      renderCell: (params) => {
        const onDetailsClick = () => handleOpenPopup(params.row.team);
        if (params.row.team)
          return (
            <div>
              <Link component="button" onClick={onDetailsClick} underline="always">
                Pit Data
              </Link>
            </div>
          );
      },
    },
    {
      field: "amp_total",
      headerName: "Amp",
      filterable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
    },
    {
      field: "speaker_total",
      headerName: "Speaker",
      filterable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.75,
      minWidth: 80
    },
    {
      field: "pass",
      headerName: "Pass",
      filterable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
      minWidth: 75
    },
    {
      field: "endgame_points",
      headerName: "End Game",
      filterable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
      minWidth: 90,
    },
    {
      field: "climbing",
      headerName: "Climb",
      filterable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
      minWidth: 75,
    },
    {
      field: "mic",
      headerName: "Mic",
      filterable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
      minWidth: 75,
    },
    {
      field: "OPR",
      headerName: "OPR",
      filterable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
      minWidth: 65,
    },
  ]);

  const statisticsTeamOnClick = (cellValues) => {
    history.push("team-" + cellValues.team);
  };

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
            <Typography>{children}</Typography>
          </Box>
        )}
      </div>
    );
  }

  const scoutingDataCallback = (data, idx, alliance) => {
    if (alliance === 'red') {
      setRedScouting(prevData => {
        // Create a new array with updated data
        const updatedData = [...prevData];
        updatedData[idx] = data;
        return updatedData;
      });
    } else {
      setBlueScouting(prevData => {
        // Create a new array with updated data
        const updatedData = [...prevData];
        updatedData[idx] = data;
        return updatedData;
      });
    }
  };

  const [openPopup, setOpenPopup] = useState(false);
  const [selectedTeam, setSelectedTeam] = useState(null);

  // Function to handle opening the pop-up
  const handleOpenPopup = (team) => {
    history.push(`#${team}`);
    setSelectedTeam(team);
    setOpenPopup(true);
  };

  const matchInfoCallback = async (restData) => {
    setData(restData)
    let newRow = {};
    const blueAutoRows = [];
    let i = 0;
    let blueMicPoints = 0;
    let blueAmpTotal = 0;
    let blueSpeakerTotal = 0;
    let blueFeedingTotal = 0;
    let blueEndgamePoints = 0;
    let blueClimbing = 0;
    getTeamScoutingData(year, eventKey, restData.blue_teams[0].key, (data) => scoutingDataCallback(data, 0, "blue"))
    getTeamScoutingData(year, eventKey, restData.blue_teams[1].key, (data) => scoutingDataCallback(data, 1, "blue"))
    getTeamScoutingData(year, eventKey, restData.blue_teams[2].key, (data) => scoutingDataCallback(data, 2, "blue"))
    for (const team of restData?.blue_teams) {
      newRow = {
        key: i,
        team: team.key.replace("frc", ""),
        OPR: team.OPR.toFixed(1),
        amp_total: team.amp_total.toFixed(1),
        speaker_total: team.speaker_total.toFixed(1),
        pass: team?.pass?.toFixed(1),
        endgame_points: team.endgame_points.toFixed(1),
        climbing: team.climbing.toFixed(1),
        mic: team.mic.toFixed(1),
      };
      blueAutoRows.push(newRow);
      i = i + 1;
      blueMicPoints += team.mic
      blueAmpTotal += team.amp_total
      blueSpeakerTotal += team.speaker_total
      blueFeedingTotal += team.pass
      blueEndgamePoints += team.endgame_points
      blueClimbing += team.climbing
    }
    newRow = {
      key: 4,
      team: "",
      OPR: restData?.prediction.blue_score.toFixed(1),
      amp_total: blueAmpTotal.toFixed(1),
      speaker_total: blueSpeakerTotal.toFixed(1),
      pass: blueFeedingTotal.toFixed(1),
      endgame_points: blueEndgamePoints.toFixed(1),
      climbing: blueClimbing.toFixed(1),
      mic: blueMicPoints.toFixed(1),
    };
    blueAutoRows.push(newRow);

    setBlueRows(blueAutoRows);
    const redAutoRows = [];
    i = 0;
    let redMicPoints = 0;
    let redAmpTotal = 0;
    let redSpeakerTotal = 0;
    let redFeedingTotal = 0;
    let redEndgamePoints = 0;
    let redClimbing = 0;

    getTeamScoutingData(year, eventKey, restData.red_teams[0].key, (data) => scoutingDataCallback(data, 0, "red"))
    getTeamScoutingData(year, eventKey, restData.red_teams[1].key, (data) => scoutingDataCallback(data, 1, "red"))
    getTeamScoutingData(year, eventKey, restData.red_teams[2].key, (data) => scoutingDataCallback(data, 2, "red"))
    for (const team of restData?.red_teams) {
      // console.log(team)
      newRow = {
        key: i,
        team: team.key.replace("frc", ""),
        OPR: team.OPR.toFixed(1),
        amp_total: team.amp_total.toFixed(1),
        speaker_total: team.speaker_total.toFixed(1),
        pass: team?.pass?.toFixed(1),
        endgame_points: team.endgame_points.toFixed(1),
        climbing: team.climbing.toFixed(1),
        mic: team.mic.toFixed(1),
      };
      redAutoRows.push(newRow);
      i = i + 1;
      redMicPoints += team.mic
      redAmpTotal += team.amp_total
      redSpeakerTotal += team.speaker_total
      redFeedingTotal += team.pass
      redEndgamePoints += team.endgame_points
      redClimbing += team.climbing
    }
    newRow = {
      key: 4,
      team: "",
      OPR: restData?.prediction.red_score.toFixed(1),
      amp_total: redAmpTotal.toFixed(1),
      speaker_total: redSpeakerTotal.toFixed(1),
      pass: redFeedingTotal.toFixed(1),
      endgame_points: redEndgamePoints.toFixed(1),
      climbing: redClimbing.toFixed(1),
      mic: redMicPoints.toFixed(1),
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
      ${Math.round(restData?.prediction?.blue_total_rp)} RPs`);
    setRedPrediction(`${Math.round(restData?.prediction?.red_score)} Points,  
      ${Math.round(restData?.prediction?.red_total_rp)} RPs`);
    setRedTitle(
      ": " +
      String(Math.round(restData?.prediction?.red_score)) +
      " Points, " +
      String(Math.round(restData?.prediction?.red_win_rp)) +
      " RPs"
    );

    setLoading(false);
  };

  function a11yProps(index) {
    return {
      id: `full-width-tab-${index}`,
      "aria-controls": `full-width-tabpanel-${index}`,
    };
  }

  useEffect(() => {
    const url = new URL(window.location.href);
    const params = url.pathname.split("/");
    const year = params[3];
    const eventKey = params[4];
    const match = params[5].split("-")[1];
    setMatchNumber(match);
    getMatchDetails(year, eventKey, match, matchInfoCallback);
  }, []);

  const handleChange = (event, newValue) => {
    const url = new URL(window.location.href);
    const params = url.pathname.split("/");
    const year = params[3];
    const eventKey = params[4];
    const team = params[5].replace("team-", "");
    history.push({ hash: tabDict[newValue] });
    setValue(newValue);
    setTabIndex(newValue)
    getTeamPictures(year, eventKey, team, picturesCallback)
  };

  const picturesCallback = (data) => {
    const rows = data.map((item) => (
      <ImageListItem
        style={{ cursor: 'context-menu' }}
      >
        <img src={item.file} alt="Image" />
      </ImageListItem>
    ));
    setPictures(rows);
  };

  return (
    <>
      <div style={{ height: "calc(100vh - 132px)", width: "100%", overflow: "auto" }}>
        <AppBar position="static">
          <Tabs
            value={value}
            onChange={handleChange}
            indicatorColor="secondary"
            textColor="inherit"
            variant="fullWidth"
            aria-label="full width tabs"
          >
            <Tab icon={<Assignment />} label="Stats" {...a11yProps(0)} />
            <Tab icon={<PrecisionManufacturing style={{ color: "red" }} />} label="Autos Red" {...a11yProps(1)} />
            <Tab icon={<PrecisionManufacturing style={{ color: "darkblue" }} />} label="Autos Blue" {...a11yProps(2)} />
          </Tabs>
        </AppBar>
        <TabPanel value={value} index={0} dir={darkTheme.direction}>
          <ThemeProvider theme={darkTheme}>
            <Dialog open={openPopup} onClose={() => setOpenPopup(false)}>
              <DialogTitle sx={{ backgroundColor: "#1a174d", color: "#1976d2" }}>{`Details for Team ${selectedTeam}`}</DialogTitle>
              <DialogContent sx={{ backgroundColor: "#1a174d" }}>
                <PitScoutingForm teamPage={true}/>
              </DialogContent>
            </Dialog>
            <Container>
              <Row>
                <div style={{ width: "100%" }}>
                  <Card className="polar-box">
                    <CardHeader className="bg-transparent" style={{ textAlign: "center", display: "flex", justifyContent: "center", alignItems: "center" }}>
                      <h1 className="text-white mb-0">Match {matchTitle}</h1>
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
                  <Card className="polar-box">
                    <DrawingCanvas backgroundImageSrc={serverPath + "/2024GameField.png"} />
                  </Card>
                </div>
              </Row>
            </Container>
          </ThemeProvider>
        </TabPanel>
        <TabPanel value={value} index={1} dir={darkTheme.direction}>
          <div style={{ width: "100%" }}>
            <Card className="polar-box">
              <CardHeader className="bg-transparent" style={{ textAlign: "center", display: "flex", justifyContent: "center", alignItems: "center" }}></CardHeader>
              <DrawingCanvas backgroundImageSrc={serverPath + "/2024GameField.png"} />
              <ImageList cols={3}>
                {[0, 1, 2].map((i) => {
                  return (
                    <div style={{ backgroundColor: i === 1 ? "#323a70" : "" }}>
                      <h1 className="text-white mb-0" style={{ textAlign: "center" }}>Team: {data?.red_teams?.[i].key.replace("frc", "")}</h1>
                      {redScouting[i].length > 0 ? <ImageList cols={2}>
                        {redScouting[i].map((val) => { return <><AutoDisplay scoutingData={val} /></> })}
                      </ImageList>
                        : <h2 className="text-white mb-0" style={{ textAlign: "center" }}>No Auto Data</h2>}
                    </div>
                  )
                })}
              </ImageList>
            </Card>
          </div>
        </TabPanel>
        <TabPanel value={value} index={2} dir={darkTheme.direction}>
          <div style={{ width: "100%" }}>
            <Card className="polar-box">
              <CardHeader className="bg-transparent" style={{ textAlign: "center", display: "flex", justifyContent: "center", alignItems: "center" }}></CardHeader>
              <DrawingCanvas backgroundImageSrc={serverPath + "/2024GameField.png"} />
              <ImageList cols={3}>
                {[0, 1, 2].map((i) => {
                  return (
                    <div style={{ backgroundColor: i === 1 ? "#323a70" : "" }}>
                      <h1 className="text-white mb-0" style={{ textAlign: "center" }}>Team: {data?.blue_teams?.[i].key.replace("frc", "")}</h1>
                      {blueScouting[i].length > 0 ? <ImageList cols={2}>
                        {blueScouting[i].map((val) => { return <><AutoDisplay scoutingData={val} /></> })}
                      </ImageList>
                        : <h2 className="text-white mb-0" style={{ textAlign: "center" }}>No Auto Data</h2>}
                    </div>
                  )
                })}
              </ImageList>
            </Card>
          </div>
        </TabPanel>
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

export default Match;
