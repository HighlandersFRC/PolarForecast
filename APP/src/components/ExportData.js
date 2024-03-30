import React, { useEffect, useState } from 'react';
import Button from '@mui/material/Button';

function ExportToCSV({ rows, columns }) {
    const [dataRows, setDataRows] = useState(rows)
    const [dataColumns, setDataColumns] = useState(columns)
    useEffect(() => {
        setDataRows(rows)
        // console.log(rows)
    }, [rows])
    useEffect(() => {
        setDataColumns(columns)
        // console.log(columns)
    }, [columns])
    const exportToCSV = () => {
        // console.log("Exporting to CSV...");
        // console.log(dataRows, dataColumns)
        // Define current date and time
        const today = new Date();
        const year = today.getFullYear();
        const month = (today.getMonth() + 1).toString().padStart(2, '0');
        const day = today.getDate().toString().padStart(2, '0');
        const dayOfWeek = ['sun', 'mon', 'tue', 'wed', 'thur', 'fri', 'sat'][today.getDay()];
        const hours = today.getHours();
        const minutes = today.getMinutes();
        const seconds = today.getSeconds();
        const amOrPm = hours >= 12 ? 'pm' : 'am';
        const time = `${hours % 12 || 12}-${minutes}-${seconds}-${amOrPm}`;

        let csvContent = "";

        // Write header row
        const headerRow = dataColumns.map(column => column.headerName);
        csvContent += headerRow.join(",") + "\r\n";

        // Write data rows
        dataRows.forEach(row => {
            const rowData = dataColumns.map(column => {
                const field = column.field;
                return row[field] !== undefined && row[field] !== null ? row[field] : '';
            });
            csvContent += rowData.join(",") + "\r\n";
        });

        // console.log("CSV content:", csvContent);

        // Create Blob
        const blob = new Blob([csvContent], { type: 'text/csv' });

        // Create temporary URL for the Blob
        const url = URL.createObjectURL(blob);

        // Create a temporary link element to trigger the download
        const link = document.createElement("a");
        link.setAttribute("href", url);
        link.setAttribute("download", `Polar_Forecast_${year}_${month}-${day}-${dayOfWeek}_${time}.csv`);
        document.body.appendChild(link);

        // Trigger the download
        link.click();

        // Cleanup
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
    };

    return (
        <Button variant="contained" fullWidth onClick={exportToCSV}>
            Export to CSV
        </Button>
    );
}

export default ExportToCSV;
