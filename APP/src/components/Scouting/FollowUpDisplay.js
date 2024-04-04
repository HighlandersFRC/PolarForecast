import { FormControl, InputLabel, MenuItem, Select, TextField } from "@mui/material";

const { getFollowUp } = require("api");
const { useState, useEffect } = require("react");

const FollowUpDisplay = ({team}) => {
    const url = new URL(window.location.href);
    const params = url.pathname.split("/");
    const year = params[3];
    const eventKey = params[4];
    const [deaths, setDeaths] = useState([])
    useEffect(() => {
        getFollowUp(year, eventKey, "frc" + String(team), followUpCallback)
    }, []);
    const followUpCallback = async (data) => {
        setDeaths(data?.deaths || [])
    }
    return (<>
        {deaths.length > 0 ? deaths.map((death, idx) => (
            <div key={idx}>
                <br />
                <h2 className="text-white mb-0">Death #{idx + 1}</h2>
                <br />
                <TextField
                    label="Match Number"
                    variant="outlined"
                    type="number"
                    fullWidth
                    name="match_number"
                    value={death.match_number}
                    disabled
                />
                <br />
                <br />
                <TextField
                    label="Reason for Team Death"
                    variant="outlined"
                    fullWidth
                    name="death_reason"
                    disabled
                    multiline
                    value={death.death_reason}
                />
                <br />
                <br />
                <FormControl variant="outlined" fullWidth>
                    <InputLabel id="severity">Severity</InputLabel>
                    <Select
                        labelId="severity"
                        label="Severity"
                        fullWidth
                        name="severity"
                        disabled
                        value={death.severity}
                    >
                        <MenuItem value={1}>1 (One time error)</MenuItem>
                        <MenuItem value={2}>2 (Can Be Fixed Before Elims)</MenuItem>
                        <MenuItem value={3}>3 (Permanently Broken)</MenuItem>
                    </Select>
                </FormControl>
                <br />
                <br />
            </div>
        )) : <><h2 className="text-white mb-0">No Deaths Found</h2></>
        }
    </>
    )
}
export default FollowUpDisplay