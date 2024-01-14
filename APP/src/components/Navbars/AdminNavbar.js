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
import { Link } from "react-router-dom";
// reactstrap components
import {
  Navbar,
  Container
} from "reactstrap";
import * as React from 'react';
import TextField from '@mui/material/TextField';
import Autocomplete from '@mui/material/Autocomplete';
import {getSearchKeys} from "api.js";


const AdminNavbar = (props) => {

  const [searchKeys, setSearchKeys] = React.useState([]);

  const searchKeyCallback = async(data)=>{
    const terms = [];
    for(let i=0; i< data.data.length; i++){
      terms.push({"label":String(data.data[i].display), "page": data.data[i].page});
    }
    setSearchKeys(terms);
  }


  React.useEffect(()=> {
    getSearchKeys(searchKeyCallback)

  }, []);
  return (
    <>
      <Navbar className="navbar-top navbar-dark" expand="md" id="navbar-main">
        <Container fluid>
          <Link
            className="h4 mb-0 text-white text-uppercase d-none d-lg-inline-block"
            to="/"
          >
            {props.brandText}
          </Link>
          <Autocomplete
            className="navbar-search navbar-search-dark form-inline mr-3 d-none d-md-flex ml-lg-auto"
            disablePortal
            id="combo-box-demo"
            options={
              searchKeys? searchKeys : []
            }
            sx={{ width: 300 }}
              renderInput={(params) => <TextField {...params} label="Search" />}
              onChange={(event, newValue) => {
              window.location.href=newValue.page;
            }}
          />
        </Container>
      </Navbar>
    </>
  );
};

export default AdminNavbar;
