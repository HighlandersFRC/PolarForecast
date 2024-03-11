import * as React from "react";
import Grid from "@mui/material/Grid";
import Typography from "@mui/material/Typography";

const Footer = () => {
  return (
    <Grid
      container
      component="footer"
      justifyContent="center"
      sx={{ position: "absolute", bottom: 0, width: "100%", padding: 0 }}
    >
    </Grid>
  );
};

export default Footer;
