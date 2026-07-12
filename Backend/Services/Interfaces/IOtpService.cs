namespace Backend.Services.Interfaces
{
    public interface IOtpService
    {
        Task<string> GenerateAndSaveOtpAsync(string email, string purpose);
        Task<bool> VerifyOtpAsync(string email, string otp, string purpose);
    }
}
