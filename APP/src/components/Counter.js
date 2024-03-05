import { useState } from "react";
import { Container, ButtonGroup, Button, TextField } from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import RemoveIcon from "@mui/icons-material/Remove";

const Counter = ({ label, onChange, value, max}) => {
  const [count, setCount] = useState(value);

  const handleChange = (event) => {
    const newValue = Math.max(Number(event.target.value), 0);
    onChange(newValue);
    setCount(newValue);
  };

  return (
    <Container>
      <ButtonGroup>
        <Button
          onClick={() => {
            const newValue = Math.max(count - 1, 0);
            onChange(newValue);
            setCount(newValue);
          }}
          disabled={count === 0}
        >
          <RemoveIcon fontSize="small" />
        </Button>
        <TextField
          label={label}
          size="small"
          onChange={handleChange}
          value={count}
          type="number"
        />
        <Button
          onClick={() => {
            const newValue = Math.min(count + 1, max || 9);
            onChange(newValue);
            setCount(newValue);
          }}
        >
          <AddIcon fontSize="small" />
        </Button>
      </ButtonGroup>
    </Container>
  );
};

export default Counter;
