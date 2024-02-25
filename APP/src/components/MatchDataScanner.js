import { Button } from "@mui/material";
import { postMatchScouting , putMatchScouting} from "api";
import React, { useState } from "react";
import QrReader from "react-web-qr-reader";

const MatchDataScanner = () => {
    const delay = 500;

    const previewStyle = {
        height: 240,
        width: 320
    };

    const [result, setResult] = useState("No result");
    const [show, setShow] = useState(true)
    const [statusText, setStatusText] = useState("")
    const [update, setUpdate] = useState(false)

    const handleScan = (result) => {
        if (result?.data) {
            setResult(result?.data);
        }
    };

    const handleError = (error) => {
        console.log(error);
    };

    const handleSubmit = () => {
        // Set the "Time" field to the current UTC timestamp when submitting the form
        try {
            setStatusText("Submitting...")
            setShow(false)
            postMatchScouting(JSON.parse(result), (data) => MatchScoutingStatusCallback(data, false));
        } catch {
            setShow(false)
            setStatusText("Invalid entry")
        }
    };

    const MatchScoutingStatusCallback = ([status, response], update) => {
        if (!update) {
            if (status === 200) {
                setStatusText("Submission Successful")
            } else if (status === 307) {
                setUpdate(true)
                setStatusText("There is already an entry for this match. Do you want to update it?")
            } else {
                setStatusText(response.detail)
            }
        } else {
            if (status === 200) {
                setUpdate(false)
                setStatusText("Submission Successful")
            } else {
                setStatusText(response.detail)
            }
        }
    }

    const handleUpdate = () => {
        // Set the "Time" field to the current UTC timestamp when submitting the form
        try {
            setStatusText("Submitting...")
            setShow(false)
            putMatchScouting(JSON.parse(result), (data) => MatchScoutingStatusCallback(data, true));
        } catch {
            setShow(false)
            setStatusText("Invalid entry")
        }
    };

    const tryAgain = () => {
        setShow(true)
        setResult("No Result")
    }

    return (
        <>
            {show && <>
                <QrReader
                    delay={delay}
                    style={previewStyle}
                    onError={handleError}
                    onScan={handleScan}
                />
                <br/>
                <br/>
                <br/>
                <br/>
                <p className="text-white mb-0">{result}</p>
                <Button variant="contained" onClick={handleSubmit}>
                    Submit
                </Button>
            </>}
            {!show && <>
                <h1 className="text-white mb-0">{statusText}</h1>
                {update && <Button variant="contained" onClick={handleUpdate}>
                    Update
                </Button>}
                <Button variant="contained" onClick={tryAgain}>
                    Scan Again
                </Button>
            </>
            }
        </>
    );
};

export default MatchDataScanner;
