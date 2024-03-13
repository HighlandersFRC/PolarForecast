import { Button, TextField } from "@mui/material";
import { postMatchScouting, putMatchScouting } from "api";
import React, { useState } from "react";
import QrReader from "react-web-qr-reader";

const MatchDataScanner = () => {
  const delay = 500;

  const previewStyle = {
    height: 240,
    width: 320
  };

  const [result, setResult] = useState("");
  const [show, setShow] = useState(true);
  const [statusText, setStatusText] = useState("");
  const [update, setUpdate] = useState(false);

  const handleScan = (result) => {
    if (result?.data) {
      setResult(result?.data);
    }
  };

  const handleError = (error) => {
    console.log(error);
  };

  const handleSubmit = () => {
    let dataToSubmit = result;

    if (dataToSubmit.trim() !== "") {
      setStatusText("Submitting...");
      setShow(false);
      if (update) {
        putMatchScouting(JSON.parse(dataToSubmit), (data) =>
          MatchScoutingStatusCallback(data, true)
        );
      } else {
        postMatchScouting(JSON.parse(dataToSubmit), (data) =>
          MatchScoutingStatusCallback(data, false)
        );
      }
    } else {
      setStatusText("No data to submit");
    }
  };

  const MatchScoutingStatusCallback = ([status, response], update) => {
    if (!update) {
      if (status === 200) {
        setStatusText("Submission Successful");
      } else if (status === 307) {
        setUpdate(true);
        setStatusText(
          "There is already an entry for this match. Do you want to update it?"
        );
      } else {
        setStatusText(response.detail);
      }
    } else {
      if (status === 200) {
        setUpdate(false);
        setStatusText("Update Successful");
      } else {
        setStatusText(response.detail);
      }
    }
  };

  const handleUpdate = () => {
    let dataToSubmit = result;

    if (dataToSubmit.trim() !== "") {
      setStatusText("Submitting...");
      setShow(false);
      putMatchScouting(JSON.parse(dataToSubmit), (data) =>
        MatchScoutingStatusCallback(data, true)
      );
    } else {
      setStatusText("No data to submit");
    }
  };

  const tryAgain = () => {
    setShow(true);
    setResult("");
  };

  return (
    <>
      {show && (
        <>
          <QrReader
            delay={delay}
            style={previewStyle}
            onError={handleError}
            onScan={handleScan}
          />
          <br />
          <br />
          <br />
          <br />
          <TextField
            label="Data"
            value={result}
            onChange={(e) => setResult(e.target.value)}
            fullWidth
          />
          <br />
          <br />
          <Button variant="contained" onClick={handleSubmit}>
            Submit
          </Button>
        </>
      )}
      <h1 className="text-white mb-0">{statusText}</h1>
      {!show && (
        <>
          {update && (
            <Button variant="contained" onClick={handleUpdate}>
              Update
            </Button>
          )}
          <Button variant="contained" onClick={tryAgain}>
            Scan Again
          </Button>
        </>
      )}
    </>
  );
};

export default MatchDataScanner;
