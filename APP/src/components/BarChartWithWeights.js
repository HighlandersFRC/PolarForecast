import React, { useEffect, useState } from "react";
import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { TextField, Box } from "@mui/material";

const styles = {
  weightInput: {
    width: 80, // Adjust the width as needed
    marginRight: 10, // Add some spacing
  },
};

function BarChartWithWeights({ data, number, startingFields }) {
  const [fields, setFields] = useState(startingFields || []);
  const [originalData, setOriginalData] = useState(data || []);
  const [chartData, setChartData] = useState(originalData);
  const [chartDataKey, setChartDataKey] = useState(Date.now().toString());

  const chartPalette = ["#4D9DE0", "#E15554", "#7768AE", "#3BB273"];

  const handleWeightChange = (event, key) => {
    let newFields = [...fields];
    const field = newFields.find((item) => item.key === key);
    field.weight = event.target.value;
    setFields(newFields);
    updateData(newFields);
  };

  const updateData = (fields) => {
    const adjustedData = originalData.map((item) => {
      let newItem = { ...item };

      for (const field of fields) {
        if (field.enabled) {
          newItem[field.key] = (Number(item[field.key]) * Number(field.weight || 1)).toFixed(1);
        }
      }

      return newItem;
    });

    // Sort the adjustedData by the total value
    adjustedData.sort((a, b) => {
      let aTotal = 0;
      let bTotal = 0;

      for (const field of fields) {
        if (field.enabled) {
          aTotal += Number(a[field.key]);
          bTotal += Number(b[field.key]);
        }
      }

      return bTotal - aTotal;
    });

    setChartData(adjustedData);
    setChartDataKey(Date.now().toString()); // Update the key to trigger re-render
  };

  useEffect(() => {
    updateData(fields);
  }, [fields]);

  return (
    <div>
      <ResponsiveContainer width="100%" height={500}>
        <BarChart
          key={chartDataKey}
          data={chartData.slice(0, number)}
          margin={{ top: 10, left: -20, right: 15, bottom: 20 }}
        >
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="key" angle={-90} textAnchor="end" interval={0} />
          <YAxis />
          <Tooltip formatter={(value) => (typeof value === 'number' ? value.toFixed(1) : value)} />
          {fields.map((item) => {
            return (
              item.enabled && (
                <Bar
                  key={item.key}
                  dataKey={item.key}
                  fill={chartPalette[item.index]}
                  name={item.name}
                  stackId="a"
                  animationDuration={500} // Set animation duration (milliseconds)
                />
              )
            );
          })}
        </BarChart>
      </ResponsiveContainer>

      <br />
      <div style={{ display: "flex" }}>
        {fields.map((item) => {
          return (
            item.enabled && (
              <Box key={item.key} style={styles.weightInput}>
                <TextField
                  type="number"
                  label={item.name}
                  value={item.weight || 1}
                  onChange={(event) => handleWeightChange(event, item.key)}
                />
              </Box>
            )
          );
        })}
      </div>
    </div>
  );
}

export default BarChartWithWeights;
