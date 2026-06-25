public class NGMCP_PasswordUtil {
    public static String generateTempPassword() {
        return 'Tmp@' +
            String.valueOf(
                Math.mod(Crypto.getRandomInteger(), 1000000)
            );
    }
}