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
import AppBar from "@mui/material/AppBar";
import Tabs from "@mui/material/Tabs";
import Tab from "@mui/material/Tab";
import Typography from "@mui/material/Typography";
import Link from "@mui/material/Link";
import Box from "@mui/material/Box";
import React, { useEffect, useState } from "react";
import CircularProgress from "@mui/material/CircularProgress";
import Stack from "@mui/material/Stack";
import { getStatDescription, getTeamStatDescription, getTeamMatchPredictions } from "api.js";
import { ThemeProvider, createTheme } from "@mui/material/styles";
import { useHistory } from "react-router-dom";
import EmojiEventsIcon from "@mui/icons-material/EmojiEvents";
import MoodBadIcon from "@mui/icons-material/MoodBad";
import { DataGrid, gridClasses } from "@mui/x-data-grid";
import { getTeamPictures } from "api";
import { Button, ImageList, ImageListItem, Popover, TextField } from "@mui/material";
import ImageWithPopup from "components/ImageWithPopup";
import { deleteTeamPictures } from "api";
import { getTeamScoutingData } from "api";
import { deactivateMatchData } from "api";
import { activateMatchData } from "api";
import AutoDisplay from "components/AutosDisplay";

const Team = () => {
  const history = useHistory();
  const tabDict = ["schedule", "team-stats", "pictures", "match-scouting", "autos"];
  const url = new URL(window.location.href);
  const params = url.pathname.split("/");
  const year = params[3];
  const eventKey = params[4];
  const team = params[5].replace("team-", "");
  const [tabIndex, setTabIndex] = useState(0);
  const [pictures, setPictures] = React.useState([]);
  const [loading, setLoading] = React.useState(true);
  const [teamInfo, setTeamInfo] = React.useState("");
  const [statDescription, setStatDescription] = useState([]);
  const [scoutingKeys, setScoutingKeys] = useState([]);
  const [keys, setKeys] = useState([]);
  const [reportedStats, setReportedStats] = useState([]);
  const [value, setValue] = React.useState(0);
  const [teamNumber, setTeamNumber] = useState();
  const [scoutingData, setScoutingData] = useState([])
  const [scoutingColumns, setScoutingColumns] = useState([]);
  const [scoutingRows, setScoutingRows] = useState([]);
  const [columns, setColumns] = useState([
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
      field: "alliance_color",
      headerName: "Color",
      sortable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
      renderCell: (params) => {
        if (params.value.toLowerCase() === "red") {
          return (
            <Typography fontWeight="bold" color="#FF0000">
              {params.value}
            </Typography>
          );
        } else {
          return (
            <Typography fontWeight="bold" color="primary">
              {params.value}
            </Typography>
          );
        }
      },
    },
    {
      field: "blue_score",
      headerName: "Blue Score",
      sortable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
      renderCell: (params) => {
        let showTrophy = false;
        if (params.row.data_type === "Result") {
          showTrophy = true;
        }
        if (parseFloat(params.row.blue_score) > parseFloat(params.row.red_score)) {
          if (params.row.alliance_color.toLowerCase() === "blue") {
            return (
              <Typography fontWeight="bold" color="primary">
                {showTrophy && <EmojiEventsIcon />} {params.value}
              </Typography>
            );
          } else {
            return (
              <Typography fontWeight="bold" color="primary">
                {showTrophy && <MoodBadIcon />} {params.value}
              </Typography>
            );
          }
        } else {
          return <Typography color="#FFFFFF"> {params.value}</Typography>;
        }
      },
    },
    {
      field: "red_score",
      headerName: "Red Score",
      sortable: false,
      disableExport: true,
      headerAlign: "center",
      align: "center",
      flex: 0.5,
      renderCell: (params) => {
        let showTrophy = false;
        if (params.row.data_type === "Result") {
          showTrophy = true;
        }
        if (parseFloat(params.row.blue_score) < parseFloat(params.row.red_score)) {
          if (params.row.alliance_color.toLowerCase() === "red") {
            return (
              <Typography fontWeight="bold" color="#FF0000">
                {showTrophy && <EmojiEventsIcon />} {params.value}
              </Typography>
            );
          } else {
            return (
              <Typography fontWeight="bold" color="#FF0000">
                {showTrophy && <MoodBadIcon />} {params.value}
              </Typography>
            );
          }
        } else {
          return <Typography color="#FFFFFF"> {params.value}</Typography>;
        }
      },
    },
  ]);
  const [matchesRows, setMatchesRows] = useState([]);

  const statisticsMatchOnClick = (cellValues) => {
    history.push("match-" + cellValues.key);
  };

  const teamPredictionsCallback = (data) => {
    const qual_rows = [];
    const sf_rows = [];
    const f_rows = [];
    const url = new URL(window.location.href);
    const params = url.pathname.split("/");
    const team = params[5].replace("team-", "frc");
    for (let i = 0; i < data.data.length; i++) {
      if (data.data[i].comp_level === "qm") {
        let color = "UNKOWN";
        if (data.data[i].blue_teams.find((obj) => obj === team)) {
          color = "Blue";
        } else if (data.data[i].red_teams.find((obj) => obj === team)) {
          color = "Red";
        }
        if ("blue_actual_score" in data.data[i]) {
          data.data[i].data_type = "Result";
          data.data[i].blue_score = data.data[i].blue_actual_score;
          data.data[i].red_score = data.data[i].red_actual_score;
        } else {
          data.data[i].data_type = "Predicted";
        }
        qual_rows.push({
          key: data.data[i].key,
          data_type: data.data[i].data_type,
          match_number: "QM-" + data.data[i].match_number,
          alliance_color: color,
          blue_score: data.data[i].blue_score.toFixed(0),
          red_score: data.data[i].red_score.toFixed(0),
        });
      } else if (data.data[i].comp_level === "sf") {
        let color = "UNKOWN";
        if (data.data[i].blue_teams.find((obj) => obj === team)) {
          color = "Blue";
        } else if (data.data[i].red_teams.find((obj) => obj === team)) {
          color = "Red";
        }
        if ("blue_actual_score" in data.data[i]) {
          data.data[i].data_type = "Result";
          data.data[i].blue_score = data.data[i].blue_actual_score;
          data.data[i].red_score = data.data[i].red_actual_score;
        } else {
          data.data[i].data_type = "Predicted";
        }
        sf_rows.push({
          key: data.data[i].key,
          data_type: data.data[i].data_type,
          match_key: Number(data.data[i].set_number).toFixed(0),
          match_number:
            data.data[i].comp_level.toUpperCase() +
            "-" +
            Number(data.data[i].set_number).toFixed(0),
          alliance_color: color,
          blue_score: data.data[i].blue_score.toFixed(0),
          red_score: data.data[i].red_score.toFixed(0),
        });
      } else if (data.data[i].comp_level === "f") {
        let color = "N/A";
        if (data.data[i].blue_teams.find((obj) => obj === team)) {
          color = "Blue";
        } else if (data.data[i].red_teams.find((obj) => obj === team)) {
          color = "Red";
        }
        if ("blue_actual_score" in data.data[i]) {
          data.data[i].data_type = "Result";
          data.data[i].blue_score = data.data[i].blue_actual_score;
          data.data[i].red_score = data.data[i].red_actual_score;
        } else {
          data.data[i].data_type = "Predicted";
        }
        f_rows.push({
          key: data.data[i].key,
          data_type: data.data[i].data_type,
          match_key: Number(data.data[i].match_number).toFixed(0),
          match_number:
            data.data[i].comp_level.toUpperCase() +
            "-" +
            Number(data.data[i].match_number).toFixed(0),
          alliance_color: color,
          blue_score: data.data[i].blue_score.toFixed(0),
          red_score: data.data[i].red_score.toFixed(0),
        });
      }
    }
    qual_rows.sort(function (a, b) {
      return Number(a.match_number.split("-")[1]) - Number(b.match_number.split("-")[1]);
    });
    sf_rows.sort(function (a, b) {
      return a.match_key - b.match_key;
    });
    f_rows.sort(function (a, b) {
      return a.match_key - b.match_key;
    });
    const elims_rows = sf_rows.concat(f_rows);
    const rows = qual_rows.concat(elims_rows);
    setMatchesRows(rows);
    setLoading(false);
  };

  const teamStatsCallback = (data) => {
    setTeamInfo(data);
    return data;
  };

  const statDescriptionCallback = async (data, scoutingData) => {
    setStatDescription(data);
    const tempKeys = [];
    for (let i = 0; i < data.data.length; i++) {
      const stat = data.data[i];
      if (Array.from(stat.stat_key)[0] !== "_") {
        tempKeys.push({
          key: stat.stat_key,
          name: stat.display_name,
          type: stat.stat_type
        });
      }
    }
    for (let i = 0; i < data.pitData.length; i++) {
      const stat = data.pitData[i];
      if (Array.from(stat.stat_key)[0] !== "_") {
        tempKeys.push({
          key: stat.stat_key,
          name: stat.display_name,
          type: stat.stat_type
        });
      }
    }
    setKeys(tempKeys);
    let statColumns = [];
    for (let i = 0; i < data.scoutingData.length; i++) {
      const stat = data.scoutingData[i];
      if (stat.report_stat && stat.stat_key !== "active") {
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
    statColumns.push({
      field: "active",
      headerName: "Toggle Active",
      filterable: false,
      headerAlign: "center",
      align: "center",
      minWidth: 80,
      flex: 0.5,
      renderCell: (params) => {
        const id = params.row.id
        return (
          <ActivateButton data={scoutingData[id]} />
        );
      },
    });
    setScoutingColumns(statColumns)
  };

  const updateData = (info, list) => {
    let tempValues = [];
    list.sort(function (a, b) {
      a = a.name?.toLowerCase();
      b = b.name?.toLowerCase();

      return a < b ? -1 : a > b ? 1 : 0;
    });
    const temp = {
      fieldName: "team number",
      fieldValue: teamInfo["key"]?.replace("frc", ""),
    };

    tempValues.push(temp);
    for (const key of list) {
      if (key.type === "num") {
        for (const fieldName in info) {
          if (fieldName === key.key) {
            const value = Math.round(info[fieldName] * 100) / 100;
            const temp = {
              fieldName: key.name,
              fieldValue: value,
            };
            tempValues.push(temp);
          }
        }
      } else if (key.type === "bool") {
        for (const fieldName in info) {
          if (fieldName === key.key) {
            let value = "YES"
            if (info[fieldName] == 0) {
              value = "NO"
            }
            const temp = {
              fieldName: key.name,
              fieldValue: value,
            };
            tempValues.push(temp);
          }
        }
      } else if (key.type == "str") {
        for (const fieldName in info) {
          if (fieldName === key.key) {
            let value = info[fieldName]
            const temp = {
              fieldName: key.name,
              fieldValue: value,
            };
            tempValues.push(temp);
          }
        }
      }
    }
    setReportedStats(tempValues);
  };

  const scoutingDataCallback = async (data) => {
    const returnRows = []
    setScoutingData(data)
    for (let i = 0; i < data.length; i++) {
      let row = data[i]
      let returnrow = {}
      returnrow.id = i
      returnrow.active = row.active
      returnrow.match_number = row.match_number
      returnrow.scout_name = row.scout_info.name
      returnrow.auto_speaker = row.data.auto.speaker
      returnrow.auto_amp = row.data.auto.amp
      returnrow.teleop_speaker = row.data.teleop.speaker
      returnrow.teleop_amp = row.data.teleop.amp
      returnrow.teleop_amped_speaker = row.data.teleop.amped_speaker
      returnrow.died = String(row.data.miscellaneous.died)
      returnRows.push(returnrow)
    }
    setScoutingRows(returnRows)
    getStatDescription(year, eventKey, (descriptions) => statDescriptionCallback(descriptions, data));
  };

  useEffect(() => {
    if (window.location.hash.length > 0) {
      setTabIndex(tabDict.indexOf(String(window.location.hash.split("#")[1])));
    }

    setTeamNumber(team);
    getTeamMatchPredictions(year, eventKey, "frc" + team, teamPredictionsCallback);
    getTeamStatDescription(year, eventKey, "frc" + team, teamStatsCallback);
  }, []);

  useEffect(async () => {
    await new Promise((r) => setTimeout(r, 100));
    updateData(teamInfo, keys);
  }, [teamInfo, keys]);

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

  function a11yProps(index) {
    return {
      id: `full-width-tab-${index}`,
      "aria-controls": `full-width-tabpanel-${index}`,
    };
  }

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
    getTeamScoutingData(year, eventKey, "frc" + team, scoutingDataCallback);
  };

  const picturesCallback = (data) => {
    const rows = data.map((item) => (
      <ImageWithPopup
        key={`data:image/jpeg;base64,${item.file}`} // Make sure to provide a unique key for each image
        imageUrl={`data:image/jpeg;base64,${item.file}`}
        onDelete={(password) => handleDeleteImage(item._id, password)} // Pass the index to the onDelete function
      />
    ));
    setPictures(rows);
  };

  const uploadStatusCallback = (status) => {
    if (status === 200) {
      getTeamPictures(year, eventKey, team, picturesCallback)
    } else {
      alert("deletion failed, status: " + status)
    }
  }

  const handleDeleteImage = (id, password) => {
    deleteTeamPictures(year, eventKey, team, id, password, (status) => { uploadStatusCallback(status) })
  };

  return (
    <>
      <AppBar position="static">
        <Tabs
          value={value}
          onChange={handleChange}
          indicatorColor="secondary"
          textColor="inherit" 
          variant="fullWidth"
          aria-label="full width tabs"
        >
          <Tab label="Schedule" {...a11yProps(0)} />
          <Tab label="Team Stats" {...a11yProps(1)} />
          <Tab label="Pictures" {...a11yProps(2)} />
          <Tab label="Match Scouting" {...a11yProps(3)} />
          <Tab label="Autos" {...a11yProps(4)} />
        </Tabs>
      </AppBar>
      <TabPanel value={value} index={0} dir={darkTheme.direction}>
        <div style={{ height: "calc(100vh - 180px)", width: "100%", overflow: "auto" }}>
          <ThemeProvider theme={darkTheme}>
            <Container>
              <Row>
                <div style={{ height: "calc(100vh - 250px)", width: "100%" }}>
                  <Card className="polar-box">
                    <CardHeader className="bg-transparent">
                      <h3 className="text-white mb-0">Team {teamNumber} Schedule</h3>
                    </CardHeader>
                    <div style={{ height: "calc(100vh - 250px)", width: "100%" }}>
                      {!loading ? (
                        <StripedDataGrid
                          disableColumnMenu
                          rows={matchesRows}
                          getRowId={(row) => {
                            return row.key;
                          }}
                          columns={columns}
                          pageSize={100}
                          rowsPerPageOptions={[100]}
                          rowHeight={35}
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
                      ) : (
                        <Box
                          sx={{
                            display: "flex",
                            justifyContent: "center",
                            alignItems: "center",
                            minHeight: "calc(100vh - 250px)",
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
          </ThemeProvider>
        </div>
      </TabPanel>
      <TabPanel value={value} index={1} dir={darkTheme.direction}>
        <div style={{ height: "calc(100vh - 220px)", width: "100%", overflow: "auto" }}>
          <Container>
            {!loading ? (
              Object.keys(reportedStats).map((e, i) => {
                const stat = reportedStats[i];
                return (
                  <ThemeProvider theme={darkTheme}>
                    <Box
                      sx={{
                        bgcolor: "#429BEF",
                        boxShadow: 1,
                        borderRadius: 2.5,
                        display: "inline-flex",
                        flexDirection: "column",
                        justifyContent: "center",
                        p: 1,
                        m: 0.5,
                        width: "150px",
                      }}
                    >
                      <Box sx={{ color: "text.secondary", width: "100%" }}>
                        {stat.fieldName.toUpperCase()}
                      </Box>
                      <Box
                        sx={{
                          color: "text.primary",
                          // width: "300px",
                          fontSize: 15,
                          fontWeight: "medium",
                        }}
                      >
                        {stat.fieldValue}
                      </Box>
                    </Box>
                  </ThemeProvider>
                );
              })
            ) : (
              <Box
                sx={{
                  display: "flex",
                  justifyContent: "center",
                  alignItems: "center",
                  minHeight: "calc(100vh - 250px)",
                }}
              >
                <CircularProgress />
              </Box>
            )}
          </Container>
        </div>
      </TabPanel>
      <TabPanel value={value} index={2} dir={darkTheme.direction}>
        <Card className="polar-box">
          <ImageList cols={3} variant="masonry">
            {pictures}
          </ImageList>
        </Card>
      </TabPanel>
      <TabPanel value={value} index={3} dir={darkTheme.direction}>
        <ThemeProvider theme={darkTheme}>
          <Card className="polar-box">
            <CardHeader className="bg-transparent">
              <h3 className="text-white mb-0">Team {teamNumber} Match Scouting Data</h3>
            </CardHeader>
            <div style={{ height: "calc(100vh - 250px)", width: "100%" }}>
              <StripedDataGrid
                disableColumnMenu
                rows={scoutingRows}
                getRowId={(row) => {
                  return row.id;
                }}
                columns={scoutingColumns}
                pageSize={100}
                rowsPerPageOptions={[100]}
                rowHeight={35}
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
                      No Scouting Data
                    </Stack>
                  ),
                }}
                getRowClassName={(params) =>
                  params.indexRelativeToCurrentPage % 2 === 0 ? "even" : "odd"
                }
              />
            </div>
          </Card>
        </ThemeProvider>
      </TabPanel>
      <TabPanel value={value} index={4} dir={darkTheme.direction}>
        <ThemeProvider theme={darkTheme}>
          <Card className="polar-box">
            <CardHeader className="bg-transparent">
              <h3 className="text-white mb-0">Team {teamNumber} Autos</h3>
            </CardHeader>
            <div style={{ height: "calc(100vh - 250px)", width: "100%" }}>
              <ImageList cols={3} variant="masonry">
                {scoutingData.map((val, idx, a) => {
                  return (<ImageListItem><AutoDisplay scoutingData={val} /></ImageListItem>)
                })}
              </ImageList>
            </div>
          </Card>
        </ThemeProvider>
      </TabPanel>
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

const ActivateButton = React.memo(({ data }) => {
  const [anchorEl, setAnchorEl] = useState(null);
  const [activated, setActivated] = useState(data?.active);
  const initText = (bool) => {
    if (bool) {
      return "deactivate";
    } else {
      return "activate";
    }
  };
  const [text, setText] = useState(initText(activated));
  const [password, setPassword] = useState('');

  const handleClick = (event) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClosePopover = () => {
    setAnchorEl(null);
  };

  const handleActivate = () => {
    if (activated) {
      setText("deactivating...");
      deactivateMatchData(data, password, deactivateCallback);
    } else {
      setText("activating...");
      activateMatchData(data, password, activateCallback);
    }
    handleClosePopover();
  };

  const deactivateCallback = (status) => {
    if (status === 200) {
      setText("activate");
      setActivated(false);
      data.active = false;
    } else {
      setText("deactivate");
      alert("Deactivation Failed");
    }
  };

  const activateCallback = (status) => {
    if (status === 200) {
      setText("deactivate");
      setActivated(true);
      data.active = true;
    } else {
      setText("activate");
      alert("Activation Failed");
    }
  };

  const handleChangePassword = (e) => {
    setPassword(e.target.value);
  };

  const open = Boolean(anchorEl);

  return (
    <div>
      <Button onClick={handleClick}>
        {text}
      </Button>
      <Popover
        open={open}
        anchorEl={anchorEl}
        onClose={handleClosePopover}
        anchorOrigin={{
          vertical: 'bottom',
          horizontal: 'center',
        }}
        transformOrigin={{
          vertical: 'top',
          horizontal: 'center',
        }}
      >
        <div style={{ padding: '10px' }}>
          <TextField
            label="Password"
            type="password"
            variant="outlined"
            value={password}
            onChange={handleChangePassword}
          />
          <br />
          <Button variant="contained" color="primary" onClick={handleActivate}>
            {text}
          </Button>
        </div>
      </Popover>
    </div>
  );
});

export default Team;
