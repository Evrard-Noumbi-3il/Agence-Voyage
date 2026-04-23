package com.adv.modules.booking;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.List;
import java.util.UUID;

@Service
public class SeatLockService {

    private final StringRedisTemplate redis;

    @Value("${gev.redis.seat-lock-ttl-seconds:600}")
    private long lockTtlSeconds;

    @Value("${gev.redis.seat-lock-prefix:lock:siege:}")
    private String lockPrefix;

    // Script Lua — SETNX atomique avec TTL
    // Retourne 1 si le verrou est posé, 0 si déjà occupé
    private static final DefaultRedisScript<Long> SET_IF_ABSENT_SCRIPT =
        new DefaultRedisScript<>(
            "if redis.call('SET', KEYS[1], ARGV[1], 'NX', 'EX', ARGV[2]) then " +
            "  return 1 " +
            "else " +
            "  return 0 " +
            "end",
            Long.class
        );

    // Script Lua — suppression sécurisée (vérifie que c'est bien notre verrou)
    private static final DefaultRedisScript<Long> DELETE_IF_OWNER_SCRIPT =
        new DefaultRedisScript<>(
            "if redis.call('GET', KEYS[1]) == ARGV[1] then " +
            "  return redis.call('DEL', KEYS[1]) " +
            "else " +
            "  return 0 " +
            "end",
            Long.class
        );

    public SeatLockService(StringRedisTemplate redis) {
        this.redis = redis;
    }

    /**
     * Pose un verrou sur un siège pour un voyage donné.
     * @return true si le verrou est posé, false si déjà occupé
     */
    public boolean lockSeat(UUID siegeId, UUID voyageId, UUID utilisateurId) {
        String key   = buildKey(siegeId, voyageId);
        String value = utilisateurId.toString();

        Long result = redis.execute(
            SET_IF_ABSENT_SCRIPT,
            List.of(key),
            value,
            String.valueOf(lockTtlSeconds)
        );

        return Long.valueOf(1L).equals(result);
    }

    /**
     * Libère le verrou uniquement si l'utilisateur en est le propriétaire.
     * @return true si libéré, false si le verrou appartenait à quelqu'un d'autre
     */
    public boolean unlockSeat(UUID siegeId, UUID voyageId, UUID utilisateurId) {
        String key   = buildKey(siegeId, voyageId);
        String value = utilisateurId.toString();

        Long result = redis.execute(
            DELETE_IF_OWNER_SCRIPT,
            List.of(key),
            value
        );

        return Long.valueOf(1L).equals(result);
    }

    /**
     * Vérifie si un siège est sous verrou.
     */
    public boolean isSeatLocked(UUID siegeId, UUID voyageId) {
        String key = buildKey(siegeId, voyageId);
        return Boolean.TRUE.equals(redis.hasKey(key));
    }

    /**
     * Retourne l'utilisateur qui détient le verrou, ou null si libre.
     */
    public String getLockOwner(UUID siegeId, UUID voyageId) {
        return redis.opsForValue().get(buildKey(siegeId, voyageId));
    }

    private String buildKey(UUID siegeId, UUID voyageId) {
        return lockPrefix + siegeId + ":" + voyageId;
    }
}
