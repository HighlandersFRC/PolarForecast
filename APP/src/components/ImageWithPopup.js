import React, { useState } from 'react';
import ImageListItem from '@mui/material/ImageListItem';
import Popover from '@mui/material/Popover';
import Button from '@mui/material/Button';

const ImageWithPopup = ({ imageUrl, onDelete }) => {
  const [anchorEl, setAnchorEl] = useState(null);

  const handleRightClick = (e) => {
    e.preventDefault();
    setAnchorEl(e.currentTarget);
  };

  const handlePopoverClose = () => {
    setAnchorEl(null);
  };

  const handleDeleteClick = () => {
    if (onDelete) {
      onDelete();
    }
    handlePopoverClose();
  };

  const open = Boolean(anchorEl);

  return (
    <div>
      <ImageListItem
        key={imageUrl}
        style={{ cursor: 'context-menu' }}
        onContextMenu={handleRightClick}
      >
        <img src={imageUrl} alt="Image" />
      </ImageListItem>

      <Popover
        open={open}
        anchorEl={anchorEl}
        onClose={handlePopoverClose}
        anchorOrigin={{
          vertical: 'bottom',
          horizontal: 'left',
        }}
        transformOrigin={{
          vertical: 'top',
          horizontal: 'left',
        }}
      >
        <div style={{ padding: '10px' }}>
          <Button variant="contained" color="primary" onClick={handleDeleteClick}>
            Delete Image
          </Button>
        </div>
      </Popover>
    </div>
  );
};

export default ImageWithPopup;
