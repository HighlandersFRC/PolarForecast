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
import { useState, useEffect } from "react";
import TextField from "@mui/material/TextField";
import Autocomplete from "@mui/material/Autocomplete";
import { getSearchKeys } from "api.js";
import { ThemeProvider, createTheme } from "@mui/material/styles";

const Search = (props) => {
  const [searchKeys, setSearchKeys] = useState([]);
  const width = props.width || "300px";

  const searchKeyCallback = async (data) => {
    const terms = [];
    let array = [];
    if (data?.data?.length > 0) {
      array = [...data.data];
    } else if (data?.length > 0) {
      array = [...data];
    }
    for (let i = 0; i < array.length; i++) {
      if ("display" in array[i]) {
        terms.push({ label: String(array[i].display), page: array[i].page });
      }
    }
    setSearchKeys(terms);
  };

  useEffect(() => {
    getSearchKeys(searchKeyCallback);
  }, []);

  const darkTheme = createTheme({
    palette: {
      primary: {
        main: "#00000",
      },
    },
  });

  return (
    <ThemeProvider theme={darkTheme}>
      <Autocomplete
        options={searchKeys ? searchKeys : []}
        loading
        renderInput={(params) => <TextField {...params} label="Select An Event" />}
        onChange={(event, newValue) => {
          window.location.href = newValue.page;
        }}
        sx={{
          width: { width },
          padding: 1,
        }}
      />
    </ThemeProvider>
  );
};

export default Search;
