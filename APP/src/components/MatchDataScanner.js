import { Button } from "@mui/material";
import { postMatchScouting } from "api";
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
    const handleScan = (result) => {
        if (result?.data) {
            setResult(result?.data);
        }
    };

    const handleError = (error) => {
        console.log(error);
    };

    const handleSubmit = () => {
        try {
            setShow(false)
            setStatusText("Submitting...")
            postMatchScouting(JSON.parse(result), dataCallback)
        } catch {
            setStatusText("Invalid Submission")
        }
    }

    const dataCallback = (status) => {
        if (status = 200) {
            setStatusText("Successful Submission")
        } else {
            setStatusText("Submission Failed")
        }
    }

    const tryAgain = () => {
        setShow(true)
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
                <br />
                <br />
                <br />
                <br />
                <p className="text-white mb-0">{result}</p>
                <Button variant="contained" onClick={handleSubmit}>
                    Submit
                </Button>
            </>}
            {!show &&<>
                <h1 className="text-white mb-0">{statusText}</h1>
                <Button variant="contained" onClick={tryAgain}>
                    Try Again
                </Button>
            </>
            }
        </>
    );
};

export default MatchDataScanner;
