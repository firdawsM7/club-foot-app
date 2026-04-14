-- Vérifier et corriger le rôle ADMIN pour admin@club.com

-- 1. Vérifier votre rôle actuel
SELECT id, email, nom, prenom, role, actif FROM users WHERE email = 'admin@club.com';

-- 2. Mettre à jour le rôle en ADMIN si ce n'est pas déjà le cas
UPDATE users SET role = 'ADMIN', actif = true WHERE email = 'admin@club.com';

-- 3. Vérifier que la mise à jour a fonctionné
SELECT id, email, nom, prenom, role, actif FROM users WHERE email = 'admin@club.com';

-- 4. Vérifier tous les utilisateurs ADMIN
SELECT id, email, nom, prenom, role, actif FROM users WHERE role = 'ADMIN';
