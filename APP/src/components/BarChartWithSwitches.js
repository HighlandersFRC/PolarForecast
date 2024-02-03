import React, { useEffect, useState } from "react";
import {
  Bar,
  BarChart,
  CartesianGrid,
  Legend,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { Switch, FormControlLabel, Box } from "@mui/material";

const styles = {
  switchContainer: {
    display: "flex",
    flexDirection: "row",
    justifyContent: "center",
    alignItems: "center",
  },
};

function BarChartWithSwitches({ data, number, startingFields }) {
  const [fields, setFields] = useState(startingFields || []);
  const [chartData, setChartData] = useState(data || []);
  const chartPalette = ["#4D9DE0", "#E15554", "#7768AE", "#3BB273"];
  const muiPalette = ["primary", "secondary", "tertiary", "quaternary"];

  const handleSwitchChange = (event) => {
    let newFields = [...fields];
    const field = newFields.filter((item) => item.key === event.target.name);
    newFields[field[0].index].enabled = event.target.checked;
    setFields(newFields);
  };

  const updateData = (fields) => {
    const newData = [...chartData].sort((a, b) => {
      let aTotal = 0;
      let bTotal = 0;
      for (const field of fields) {
        if (field.enabled === true) {
          aTotal += Number(a[field.key]);
          bTotal += Number(b[field.key]);
        }
      }
      return Number(bTotal) - Number(aTotal);
    });
    setChartData(newData);
  };

  useEffect(() => {
    updateData(fields);
  }, [fields]);

  return (
    <div>
      <ResponsiveContainer width="100%" height={500}>
        <BarChart data={chartData.slice(0, number)} margin={{ top: 10, left: -20, right: 15, bottom: 20 }}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="key" angle={-90} textAnchor="end" interval={0} />
          <YAxis />
          <Tooltip />
          {fields.map((item) => {
            return (
              item.enabled && (
                <Bar
                  dataKey={item.key}
                  fill={chartPalette[item.index]}
                  name={item.name}
                  stackId="a"
                />
              )
            );
          })}
        </BarChart>
      </ResponsiveContainer>

      <br />
      <div style={styles.switchContainer}>
      {fields.map((item) => {
        return (
          <FormControlLabel
            control={
              <Switch
                name={item.key}
                checked={fields[item.index].enabled}
                onChange={handleSwitchChange}
                color={muiPalette[item.index]}
                size='small'
              />
            }
            label={item.name}
          />
        );
      })}
      </div>
    </div>
  );
}
export default BarChartWithSwitches;
