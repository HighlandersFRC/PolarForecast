import React, { useState } from 'react';
import { Button, Input, Box } from '@mui/material';

const ImageUpload = ({ onUpload }) => {
  const [selectedFile, setSelectedFile] = useState(null);
  const [filePreview, setFilePreview] = useState(null);

  const handleFileChange = (event) => {
    const file = event.target.files[0];
    setSelectedFile(file);

    // Read the file and set the preview
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setFilePreview(reader.result);
      };
      reader.readAsDataURL(file);
    } else {
      setFilePreview(null);
    }
  };

  const handleUpload = () => {
    if (selectedFile) {
      // You can perform additional validation or processing here
      // For simplicity, just passing the selected file to the parent component
      onUpload(selectedFile);
      // Optionally, you can clear the selected file and preview after uploading
      setSelectedFile(null);
      setFilePreview(null);
    }
  };

  return (
    <Box
      display="flex"
      flexDirection="column"
      alignItems="center"
      justifyContent="center"
      textAlign="center"
      mt={4}
    >
      <h3 className="text-white mb-0">Image Upload</h3>
      <Input
        type="file"
        onChange={handleFileChange}
        accept="image/*"
        style={{ display: 'none' }}
        id="image-upload-input"
      />
      <label htmlFor="image-upload-input">
        <Button
          variant="contained"
          color="primary"
          component="span"
        >
          Choose File
        </Button>
      </label>
      {selectedFile && (
        <Box mt={2}>
          {filePreview && (
            <img
              src={filePreview}
              alt="Selected File Preview"
              style={{ maxWidth: '100%', maxHeight: '200px' }}
            />
          )}
          <p className="text-white mb-0">Selected File: {selectedFile.name}</p>
          <Button
            variant="contained"
            color="primary"
            onClick={handleUpload}
          >
            Upload
          </Button>
        </Box>
      )}
    </Box>
  );
};

export default ImageUpload;
