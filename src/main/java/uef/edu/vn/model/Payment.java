package uef.edu.vn.model;

import jakarta.validation.constraints.*;

public class Payment {
    
    @Min(value = 0, message = "ID thanh toán không được là số âm")
    private int id_Payment;

    @Min(value = 1, message = "ID người dùng (userId) phải hợp lệ (lớn hơn hoặc bằng 1)")
    private int userId;

    @NotBlank(message = "Số thẻ không được để trống")
    @Pattern(regexp = "^[0-9]{16,19}$", message = "Số thẻ không hợp lệ (Phải bao gồm từ 16 đến 19 chữ số, không chứa khoảng trắng hay chữ cái)")
    private String cardNumber;

    @PositiveOrZero(message = "Số dư tài khoản không được là số âm")
    @Digits(integer = 14, fraction = 2, message = "Số dư vượt quá giới hạn hoặc sai định dạng số tiền")
    private double balance;

    @NotBlank(message = "Mã PIN không được để trống")
    @Pattern(regexp = "^[0-9]{4,6}$", message = "Mã PIN không hợp lệ (Phải bao gồm đúng 4 hoặc 6 chữ số)")
    private String pinCode;

    @AssertTrue(message = "Lỗi bảo mật: Số thẻ không được chứa toàn bộ là số 0!")
    public boolean isCardNumberValid() {
        if (this.cardNumber != null) {
            return !this.cardNumber.matches("^0+$");
        }
        return true;
    }

    public Payment() {
        this.id_Payment = 0;
        this.userId = 0;
        this.cardNumber = "";
        this.balance = 0.0;
        this.pinCode = "";
    }

    public Payment(int id_Payment, int userId, String cardNumber, double balance, String pinCode) {
        this.id_Payment = id_Payment;
        this.userId = userId;
        this.cardNumber = cardNumber;
        this.balance = balance;
        this.pinCode = pinCode;
    }

    public int getId_Payment() { return id_Payment; }
    public void setId_Payment(int id_Payment) { this.id_Payment = id_Payment; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getCardNumber() { return cardNumber; }
    public void setCardNumber(String cardNumber) { this.cardNumber = cardNumber; }

    public double getBalance() { return balance; }
    public void setBalance(double balance) { this.balance = balance; }

    public String getPinCode() { return pinCode; }
    public void setPinCode(String pinCode) { this.pinCode = pinCode; }
}