import { Link } from "@mui/material";
import { useHistory } from "react-router-dom";

const TeamOnClick = (params) => {
    const history = useHistory();
    const statisticsTeamOnClick = () => {
        const url = new URL(window.location.href);
        const eventKey = url.pathname.split("/")[4];
        history.push(eventKey + "/team-" + params.value);
    };
    const onClick = () => statisticsTeamOnClick();

    return (
        <Link component="button" onClick={onClick} underline="always">
            {params.value}
        </Link>
    );
};

export default TeamOnClick;
