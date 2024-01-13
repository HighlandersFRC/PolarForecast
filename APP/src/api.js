// const API_ENDPOINT = "http://172.19.55.26:8085";
const API_ENDPOINT = "https://polarforecast.azurewebsites.net";

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
    getSearchKeys(() => {});
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
    const data = getWithExpiry(storage_name);
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
    const data = getWithExpiry("search_keys");
    if (data === null) {
      const endpoint = `${API_ENDPOINT}/search_keys`;
      console.log("Requesting Data from: " + endpoint);
      const response = await fetch(endpoint);
      if (response.ok) {
        const { data } = await response.json();
        const endTime = performance.now();
        const timeTaken = endTime - startTime;
        console.log(`GetSearchKeys API call took ${timeTaken} milliseconds`);
        setWithExpiry("search_keys", data, 30);
        callback(data);
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
