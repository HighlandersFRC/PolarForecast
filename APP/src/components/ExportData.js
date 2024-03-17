import React from 'react';
import Button from '@mui/material/Button';

function ExportToCSV({ rows, columns }) {
    const url = new URL(window.location.href);
    const serverPath = url.pathname.split("/")[0];
    const eventName = url.pathname.split("/")[3] + url.pathname.split("/")[4];
    const year = url.pathname.split("/")[3]
    const eventCode = url.pathname.split("/")[4]
    const exportToCSV = () => {
        const today = new Date();
        const month = (today.getMonth() + 1).toString().padStart(2, '0');
        const day = today.getDate().toString().padStart(2, '0');
        const dayOfWeek = ['sun', 'mon', 'tue', 'wed', 'thur', 'fri', 'sat'][today.getDay()];
        const hours = today.getHours();
        const minutes = today.getMinutes();
        const seconds = today.getSeconds();
        const amOrPm = hours >= 12 ? 'pm' : 'am';
        const time = `${hours % 12 || 12}-${minutes}-${seconds}-${amOrPm}`;
        let csvContent = "data:text/csv;charset=utf-8,";
        const headerRow = columns.map(column => column.headerName);
        csvContent += headerRow.join(",") + "\r\n";
        rows.forEach(row => {
            const rowData = columns.map(column => {
                const field = column.field;
                return row[field] !== undefined && row[field] !== null ? row[field] : '';
            });
            csvContent += rowData.join(",") + "\r\n";
        });
        const encodedUri = encodeURI(csvContent);
        const link = document.createElement("a");
        link.setAttribute("href", encodedUri);
        link.setAttribute("download", `Polar_Forecast_${year}_${eventCode}_${month}-${day}-${dayOfWeek}_${time}.csv`);
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    };

    return (
        <Button variant="contained" fullWidth onClick={exportToCSV}>
            Export to CSV
        </Button>
    );
}

export default ExportToCSV;
