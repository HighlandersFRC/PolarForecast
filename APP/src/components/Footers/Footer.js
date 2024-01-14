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
      <Typography variant="body2" color="text.secondary">
        © {new Date().getFullYear()}{" "}
      </Typography>
    </Grid>
  );
};

export default Footer;
