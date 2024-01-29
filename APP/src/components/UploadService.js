// upload-files.service.js

import { postTeamPictures } from "api";

class UploadFilesService {
  upload(year, event, team, file) {
    let formData = new FormData();
    formData.append("file", file);
    postTeamPictures(year, event, team, formData, this.callback)
  }
  callback = (status) => {
    console.log(status)
  }
}

export default new UploadFilesService();
