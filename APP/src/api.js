const API_ENDPOINT = "http://localhost:8000";
// const API_ENDPOINT = "https://highlanderscouting.azurewebsites.net";
console.log(API_ENDPOINT)

const default_ttl = 5; //5 minutes expiry time

function setWithExpiry(key, value, ttl) {
  const expiry = Math.floor(new Date().getTime() + ttl * 60 * 1000.0);
  const item = {
    value: JSON.stringify(value),
    expiry: expiry,
  };
  localStorage.setItem(key, JSON.stringify(item));
}

function getWithExpiry(key) {
  const itemStr = localStorage.getItem(key);
  // if the item doesn't exist, return null
  if (!itemStr) {
    return null;
  }
  const item = JSON.parse(itemStr);
  const now = new Date();
  // compare the expiry time of the item with the current time
  if (now.getTime() > item.expiry) {
    localStorage.removeItem(key);
    getSearchKeys(() => { });
    return null;
  }
  return JSON.parse(item.value);
}

export const getStatDescription = async (year, event, callback) => {
  try {
    const storage_name = year + event + "_stat_description";
    const data = getWithExpiry(storage_name);
    if (data === null) {
      const endpoint = `${API_ENDPOINT}/${year}/${event}/stat_description`;
      console.log("Requesting Data from: " + endpoint);
      const response = await fetch(endpoint);
      if (response.ok) {
        const data = await response.json();
        setWithExpiry(storage_name, data, default_ttl);
        callback(data);
      } else {
        callback({ data: [] });
      }
    } else {
      console.log("Using cached data for: " + storage_name);
      callback(data);
    }
  } catch (error) {
    console.error(error);
  }
};

export const getTeamStatDescription = async (year, event, team, callback) => {
  try {
    const storage_name = year + event + team + "_stats";
    const data = null //getWithExpiry(storage_name);
    if (data === null) {
      const endpoint = `${API_ENDPOINT}/${year}/${event}/${team}/stats`;
      console.log("Requesting Data from: " + endpoint);
      const response = await fetch(endpoint);
      if (response.ok) {
        const data = await response.json();
        setWithExpiry(storage_name, data, default_ttl);
        callback(data);
      } else {
        callback({ data: [] });
      }
    } else {
      console.log("Using cached data for: " + storage_name);
      callback(data);
    }
  } catch (error) {
    console.error(error);
  }
};

export const getRankings = async (year, event, callback) => {
  try {
    const storage_name = year + event + "_rankings";
    const data = getWithExpiry(storage_name);
    if (data === null) {
      const endpoint = `${API_ENDPOINT}/${year}/${event}/stats`;
      console.log("Requesting Data from: " + endpoint);
      const response = await fetch(endpoint);
      if (response.ok) {
        const data = await response.json();
        setWithExpiry(storage_name, data, default_ttl);
        callback(data);
      } else {
        callback({ data: [] });
      }
    } else {
      console.log("Using cached data for: " + storage_name);
      callback(data);
    }
  } catch (error) {
    console.error(error);
  }
};

export const getMatchPredictions = async (year, event, callback) => {
  try {
    const storage_name = year + event + "_predictions";
    const data = getWithExpiry(storage_name);
    if (data === null) {
      const endpoint = `${API_ENDPOINT}/${year}/${event}/predictions`;
      console.log("Requesting Data from: " + endpoint);
      const response = await fetch(endpoint);
      if (response.ok) {
        const data = await response.json();
        setWithExpiry(storage_name, data, default_ttl);
        callback(data);
      } else {
        callback({ data: [] });
      }
    } else {
      console.log("Using cached data for: " + storage_name);
      callback(data);
    }
  } catch (error) {
    console.error(error);
  }
};

export const getSearchKeys = async (callback) => {
  try {
    const startTime = performance.now();
    const storage_name = "search_keys"
    const data = getWithExpiry(storage_name)
    if (data === null || data === undefined) {
      const endpoint = `${API_ENDPOINT}/search_keys`;
      console.log("Requesting Data from: " + endpoint);
      const response = await fetch(endpoint);
      if (response.ok) {
        const data = await response.json();
        const endTime = performance.now();
        const timeTaken = endTime - startTime;
        console.log(`GetSearchKeys API call took ${timeTaken} milliseconds`);
        callback(data);
        setWithExpiry(storage_name, data, default_ttl)
      } else {
        callback({ data: [] });
      }
    } else {
      console.log("Using cached data for search keys");
      callback(data);
    }
  } catch (error) {
    console.error(error);
  }
};

export const getMatchDetails = async (year, event, matchKey, callback) => {
  try {
    const storage_name = matchKey + "_match_details";
    const data = getWithExpiry(storage_name);
    if (data === null) {
      const endpoint = `${API_ENDPOINT}/${year}/${event}/${matchKey}/match_details`;
      console.log("Requesting Data from: " + endpoint);
      const response = await fetch(endpoint);
      if (response.ok) {
        const data = await response.json();
        setWithExpiry(storage_name, data, default_ttl);
        callback(data);
      } else {
        callback({ data: [] });
      }
    } else {
      console.log("Using cached data for: " + storage_name);
      callback(data);
    }
  } catch (error) {
    console.error(error);
  }
};

export const getTeamMatchPredictions = async (year, event, team, callback) => {
  try {
    const storage_name = team + "_team_predictions";
    const data = getWithExpiry(storage_name);
    if (data === null) {
      const endpoint = `${API_ENDPOINT}/${year}/${event}/${team}/predictions`;
      console.log("Requesting Data from: " + endpoint);
      const response = await fetch(endpoint);
      if (response.ok) {
        const data = await response.json();
        setWithExpiry(storage_name, data, default_ttl);
        callback(data);
      } else {
        callback({ data: [] });
      }
    } else {
      console.log("Using cached data for: " + storage_name);
      callback(data);
    }
  } catch (error) {
    console.error(error);
  }
};

export const getLeaderboard = async (year, callback) => {
  try {
    const storage_name = year + "_leaderboard";
    const data = getWithExpiry(storage_name);
    if (data === null) {
      const endpoint = `${API_ENDPOINT}/${year}/leaderboard`;
      console.log("Requesting Data from: " + endpoint);
      const response = await fetch(endpoint);
      if (response.ok) {
        const data = await response.json();
        setWithExpiry(storage_name, data, default_ttl);
        callback(data);
      } else {
        callback({ data: [] });
      }
    } else {
      console.log("Using cached data for: " + storage_name);
      callback(data);
    }
  } catch (error) {
    console.error(error);
  }
};

export const postMatchScouting = async (data, callback) => {
  try {
    const endpoint = `${API_ENDPOINT}/MatchScouting/`;
    console.log(endpoint)
    let retval;
    let json = JSON.stringify(data)
    const response = await fetch(endpoint, {
      method: "POST", // *GET, POST, PUT, DELETE, etc.
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(data), // body data type must match "Content-Type" header
    });
    const detail = await response.json()
    const status = response.status
    callback([status, detail]); // parses JSON response into native JavaScript objects
  } catch (e) {
    callback([0, { detail: "Failed" }])
  }
}

export const putMatchScouting = async (data, callback) => {
  try {
    const endpoint = `${API_ENDPOINT}/MatchScouting/`;
    console.log(endpoint)
    let retval;
    let json = JSON.stringify(data)
    const response = await fetch(endpoint, {
      method: "PUT", // *GET, POST, PUT, DELETE, etc.
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(data), // body data type must match "Content-Type" header
    });
    callback([response.status, await response.json()]); // parses JSON response into native JavaScript objects
  } catch (e) {
    callback([0, { detail: "Failed" }])
    return 0
  }
}

export const postPitScouting = async (data, callback) => {
  try {
    const endpoint = `${API_ENDPOINT}/PitScouting/`;
    console.log(endpoint)
    let retval;
    let json = JSON.stringify(data)
    const response = await fetch(endpoint, {
      method: "POST", // *GET, POST, PUT, DELETE, etc.
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(data), // body data type must match "Content-Type" header
    });
    callback(response.status); // parses JSON response into native JavaScript objects
  } catch (e) {
    callback(0)
    return 0
  }
}

export const getTeamPictures = async (year, event, team, callback) => {
  try {
    const storage_name = `${year}${event}_${team}_Pictures`;
    const data = null
    if (data === null) {
      const endpoint = `${API_ENDPOINT}/${year}/${event}/frc${team}/getPictures`
      console.log("Requesting Data from: " + endpoint);
      const response = await fetch(endpoint);
      if (response.ok) {
        const data = await response.json();
        callback(data);
      } else {
        callback([]);
      }
    } else {
      console.log("Using cached data for: " + storage_name);
      callback(data);
    }
  } catch (error) {
    console.error(error);
  }
}

export const postTeamPictures = async (year, event, team, data, callback) => {
  try {
    const endpoint = `${API_ENDPOINT}/${year}/${event}/frc${team}/pictures/`;
    console.log(endpoint);
    const blob = dataURItoBlob(data);
    const formData = new FormData();
    formData.append('data', blob, 'image.jpg');
    const response = await fetch(endpoint, {
      method: 'POST',
      body: formData,
    });
    callback(response.status);
  } catch (e) {
    console.error('Error:', e);
    callback(0);
  }
};

export const deleteTeamPictures = async (year, event, team, data, password, callback) => {
  try {
    const endpoint = `${API_ENDPOINT}/${year}/${event}/${team}/${password}/DeletePictures/`;
    console.log(endpoint);
    const body = { "id": data }
    const response = await fetch(endpoint, {
      method: 'DELETE',
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });
    callback(response.status);
  } catch (e) {
    console.error('Error:', e);
    callback(0);
  }
};

// Function to convert data URI to Blob
function dataURItoBlob(dataURI) {
  const byteString = atob(dataURI.split(',')[1]);
  const mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];
  const ab = new ArrayBuffer(byteString.length);
  const ia = new Uint8Array(ab);

  for (let i = 0; i < byteString.length; i++) {
    ia[i] = byteString.charCodeAt(i);
  }

  return new Blob([ab], { type: mimeString });
}

export const getPitStatus = async (year, event, callback) => {
  try {
    const storage_name = `${year}${event}_PitStatus`;
    const endpoint = `${API_ENDPOINT}/${year}/${event}/pitStatus`
    console.log("Requesting Data from: " + endpoint);
    const response = await fetch(endpoint);
    if (response.ok) {
      const data = await response.json();
      setWithExpiry(storage_name, data, default_ttl);
      callback(data);
    } else {
      callback([]);
    }
  } catch (error) {
    console.error(error);
  }
}

export const getPitScoutingData = async (year, event, team, callback) => {
  try {
    const storage_name = `${year}${event}_${team}_pitData`;
    const data = null
    if (data === null) {
      const endpoint = `${API_ENDPOINT}/${year}/${event}/${team}/PitScouting`;
      console.log("Requesting Data from: " + endpoint);
      const response = await fetch(endpoint);
      if (response.status == 200) {
        const data = await response.json();
        setWithExpiry(storage_name, data, default_ttl);
        callback(data);
      } else {
        callback({});
      }
    } else {
      console.log("Using cached data for: " + storage_name);
      callback(data);
    }
  } catch (error) {
    console.error(error);
  }
}

export const getTeamScoutingData = async (year, event, team, callback) => {
  try {
    const storage_name = `${year}${event}_${team}_pitData`;
    const data = null
    if (data === null) {
      const endpoint = `${API_ENDPOINT}/${year}/${event}/${team}/ScoutEntries`;
      console.log("Requesting Data from: " + endpoint);
      const response = await fetch(endpoint);
      if (response.status == 200) {
        const data = await response.json();
        setWithExpiry(storage_name, data, default_ttl);
        callback(data);
      } else {
        callback([]);
      }
    } else {
      console.log("Using cached data for: " + storage_name);
      callback(data);
    }
  } catch (error) {
    console.error(error);
  }
}

export const deactivateMatchData = async (data, password, callback) => {
  try {
    const endpoint = `${API_ENDPOINT}/${password}/Deactivate`;
    console.log(endpoint)
    const response = await fetch(endpoint, {
      method: "PUT", // *GET, POST, PUT, DELETE, etc.
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(data), // body data type must match "Content-Type" header
    });
    callback(response.status); // parses JSON response into native JavaScript objects
  } catch (e) {
    callback(0)
    return 0
  }
}

export const activateMatchData = async (data, password, callback) => {
  try {
    const endpoint = `${API_ENDPOINT}/${password}/Activate`;
    console.log(endpoint)
    const response = await fetch(endpoint, {
      method: "PUT", // *GET, POST, PUT, DELETE, etc.
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(data), // body data type must match "Content-Type" header
    });
    callback(response.status); // parses JSON response into native JavaScript objects
  } catch (e) {
    callback(0)
    return 0
  }
}

export const getAutos = async (year, event, callback) => {
  try {
    const storage_name = `${year}${event}_autos`;
    const data = null
    if (data === null) {
      const endpoint = `${API_ENDPOINT}/${year}/${event}/ScoutingData`;
      console.log("Requesting Data from: " + endpoint);
      const response = await fetch(endpoint);
      if (response.status == 200) {
        const data = await response.json();
        setWithExpiry(storage_name, data, default_ttl);
        callback(data);
      } else {
        callback([]);
      }
    } else {
      console.log("Using cached data for: " + storage_name);
      callback(data);
    }
  } catch (error) {
    console.error(error);
  }
}