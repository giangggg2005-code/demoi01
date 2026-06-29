package uef.edu.vn.service;

import java.util.List;
import java.util.Map;

public interface MonitoringService {
    
    List<Map<String, Object>> getNewUserRegistrationStats(String startDate, String endDate, String timeframe);
    
    List<Map<String, Object>> getTransactionGrowthTrend(String startDate, String endDate, String timeframe);
    
    List<Map<String, Object>> getNewUsersList(String type, String startDate, String endDate, 
                                              String searchName, String searchEmail, String searchPhone);

    List<Map<String, Object>> getRecentProfileUpdates(String startDate, String endDate, 
                                                      String searchName, String searchEmail, String searchPhone);

    List<Map<String, Object>> getRecentRoleAssignments(String startDate, String endDate, 
                                                       String searchName, String searchEmail, String searchPhone);
    
    List<Map<String, Object>> getRoomFacilityHealthMetrics();
    
    List<Map<String, Object>> getZeroOrLowTicketShowtimeAlerts(int thresholdTickets);
    
  List<String> getAllPaymentMethods();

    List<Map<String, Object>> getLiveTransactionStream(int page, int size, String startDate, String endDate,
                                                   String txName, String txMinPrice, String txMaxPrice, 
                                                   String txMethod, String txId);

    int getTotalTransactionCount(String startDate, String endDate, String txName, 
                                 String txMinPrice, String txMaxPrice, String txMethod, String txId);
}