import { useEffect, useState } from "react";
import { Container, ButtonGroup, Button, TextField } from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import RemoveIcon from "@mui/icons-material/Remove";

const Counter = ({ label, onChange, value, max }) => {
  const [count, setCount] = useState(value);

  const handleChange = (event) => {
    const newValue = Math.max(Math.min(Number(event.target.value), max), 0);
    onChange(newValue);
    setCount(newValue);
  };

  useEffect(() => {
    setCount(value);
  }, [value]);

  return (
    <Container>
      <ButtonGroup>
        <Button
          onClick={() => {
            const newValue = Math.min(Math.max(count - 1, 0), max || 9);
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
            const newValue = Math.max(Math.min(count + 1, max || 9), 0);
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
