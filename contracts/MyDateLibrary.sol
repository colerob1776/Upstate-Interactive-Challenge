pragma solidity >=0.4.24;

import "./BokkyPooBahsDateTimeLibrary.sol";

/* @author -  Cole Roberts
/// @notice -  Utilizes BokkyPooBahsDateTimeLibrary to get time details for the current day
*/
library MyDateLibrary {

    /* @author -  Cole Roberts
    /// @return -  timstamp of last block mined
    */
    function getLastBlockTimeStamp() public view returns(uint256){
        return block.timestamp;
    }



    /* @author -  Cole Roberts
    /// @return - timestamp at 12AM for a given day
    */
    function getNewDayTimeStamp() public view returns(uint256){
        uint256 lastBlockTime = getLastBlockTimeStamp();
        uint256 currentYear = BokkyPooBahsDateTimeLibrary.getYear(lastBlockTime);
        uint256 currentMonth = BokkyPooBahsDateTimeLibrary.getMonth(lastBlockTime);
        uint256 currentDay = BokkyPooBahsDateTimeLibrary.getDay(lastBlockTime);
        uint256 zeroDayTimeStamp = BokkyPooBahsDateTimeLibrary.timestampFromDateTime(currentYear, currentMonth, currentDay, 0, 0, 0);
        return zeroDayTimeStamp;
    }


    /* @author -  Cole Roberts
    /// @dev - uses block.timestamp to get current time. passing in a UTC time externally could be used to increase precision. (~13.14 precision should be high enough)
    /// @return -  time (in seconds) elapsed since 12AM for a given day
    */
    function getCurrentTimeInDay() public view returns(uint256){
        return BokkyPooBahsDateTimeLibrary.diffSeconds(getNewDayTimeStamp(), getLastBlockTimeStamp());
    }

}