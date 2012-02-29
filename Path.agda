------------------------------------------------------------------------
-- Path
------------------------------------------------------------------------

-- Copyright (c) 2012 Favonia
-- Copyright (c) 2011-2012 Nils Anders Danielsson

{-# OPTIONS --without-K #-}

module Path where

open import Prelude

------------------------------------------------------------------------
-- Formation and introduction

private
  data path′ {ℓ} {A : Set ℓ} (x : A) : A → Set ℓ where
    refl′ : path′ x x

infix 4 _≡_

_≡_ : ∀ {ℓ} {A : Set ℓ} (x : A) → A → Set ℓ
_≡_ = path′

path : ∀ {ℓ} {A : Set ℓ} (x : A) → A → Set ℓ
path = path′

refl : ∀ {ℓ} {A : Set ℓ} (x : A) → x ≡ x
refl _ = refl′

------------------------------------------------------------------------
-- Elimination and computation

-- I think dependent pattern matching is fine, because it seems that
-- with univalence we can construct another equality with constructors
-- exposed and show two equalities are equal.

elim : ∀ {ℓ₁ ℓ₂} {A : Set ℓ₁} (P : {x y : A} → x ≡ y → Set ℓ₂) →
       (∀ x → P (refl x)) →
       ∀ {x y} (x≡y : x ≡ y) → P x≡y
elim P r refl′ = r _

------------------------------------------------------------------------
-- Congruence (respect or map) and substitutivity (tranport)

cong : ∀ {ℓ₁ ℓ₂} {A : Set ℓ₁} {B : Set ℓ₂}
       (f : A → B) {x y : A} → x ≡ y → f x ≡ f y
cong f = elim (λ {u v} _ → f u ≡ f v) (λ x → refl (f x))

subst : ∀ {ℓ₁ ℓ₂} {A : Set ℓ₁} (P : A → Set ℓ₂) {x y : A} →
        x ≡ y → P x → P y
subst P = elim (λ {u v} _ → P u → P v) (λ x p → p)

------------------------------------------------------------------------
-- Transitivity and symmetry

-- Here we makes "trans (refl _) p" definitionally equal to "p".
-- The reason is that we usually need to deal with "trans (refl (trans ...))"
-- in a complex proof of equivalence between paths.
-- (This is different from the intension of Nils' original code.)

trans : ∀ {ℓ} {A : Set ℓ} {x y z : A} → x ≡ y → y ≡ z → x ≡ z
trans {x = x} {y} {z} x≡y =
  elim
    (λ {x y} x≡y → y ≡ z → x ≡ z)
    (λ _ → id)
    x≡y

sym : ∀ {ℓ} {A : Set ℓ} {x y : A} → x ≡ y → y ≡ x
sym {x = x} x≡y = subst (λ z → x ≡ z → z ≡ x) x≡y id x≡y

------------------------------------------------------------------------
-- A must-have for beautiful proofs

infix  0 finally
infixr 0 _≡⟨_⟩_

_≡⟨_⟩_ : ∀ {a} {A : Set a} x {y z : A} → x ≡ y → y ≡ z → x ≡ z
_ ≡⟨ x≡y ⟩ y≡z = trans x≡y y≡z

finally : ∀ {a} {A : Set a} (x y : A) → x ≡ y → x ≡ y
finally _ _ x≡y = x≡y

syntax finally x y x≡y = x ≡⟨ x≡y ⟩∎ y ∎

------------------------------------------------------------------------
-- Some terminologies 

-- A type is contractible if it is inhabited and all elements are
-- equal.
Contractible : ∀ {ℓ} → Set ℓ → Set ℓ
Contractible A = ∃ λ (x : A) → ∀ y → x ≡ y
