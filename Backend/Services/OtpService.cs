using System.Security.Cryptography;
using Backend.Data;
using Backend.Domain;
using Backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Backend.Services
{
    public class OtpService : IOtpService
    {
        private readonly AppDbContext _context;

        public OtpService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<string> GenerateAndSaveOtpAsync(string email, string purpose)
        {
            var otp = GenerateSecureNumericOtp(6);
            var expirationMinutes = 10;

            // Optional: invalidate previous OTPs for the same email and purpose
            var existingOtps = await _context.OtpCodes
                .Where(o => o.Email == email && o.Purpose == purpose)
                .ToListAsync();
            
            _context.OtpCodes.RemoveRange(existingOtps);

            var otpCode = new OtpCode
            {
                Email = email,
                Code = otp,
                Purpose = purpose,
                CreatedAt = DateTime.UtcNow,
                ExpiresAt = DateTime.UtcNow.AddMinutes(expirationMinutes)
            };

            _context.OtpCodes.Add(otpCode);
            await _context.SaveChangesAsync();

            return otp;
        }

        public async Task<bool> VerifyOtpAsync(string email, string otp, string purpose)
        {
            var now = DateTime.UtcNow;
            var otpRecord = await _context.OtpCodes
                .FirstOrDefaultAsync(o => o.Email == email && o.Purpose == purpose && o.Code == otp);

            if (otpRecord == null || otpRecord.ExpiresAt < now)
            {
                return false;
            }

            // Remove it after successful verification to prevent reuse
            _context.OtpCodes.Remove(otpRecord);
            await _context.SaveChangesAsync();

            return true;
        }

        private string GenerateSecureNumericOtp(int length)
        {
            var randomNumber = new byte[length];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber);

            var result = "";
            foreach (var b in randomNumber)
            {
                result += (b % 10).ToString();
            }

            return result;
        }
    }
}
